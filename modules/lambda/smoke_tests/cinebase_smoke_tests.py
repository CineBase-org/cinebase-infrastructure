"""Read-only Cinebase smoke tests for an ECS blue/green Lambda lifecycle hook.

SMOKE_TEST_BASE_URL must route to the *new* revision through an ECS-managed
ALB test listener/rule. Do not point it at the production listener.
"""

import json
import logging
import os
from urllib.error import HTTPError, URLError
from urllib.parse import urljoin, urlsplit
from urllib.request import HTTPRedirectHandler, Request, build_opener

logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)


class SmokeTestFailure(Exception):
    pass


class NoRedirect(HTTPRedirectHandler):
    def redirect_request(self, req, fp, code, msg, headers, newurl):
        return None


_http = build_opener(NoRedirect())


def get_json(base_url: str, path: str):
    url = urljoin(base_url.rstrip('/') + '/', path.lstrip('/'))
    request = Request(
        url,
        headers={
            "Accept": "application/json",
            "X-Smoke-Test": "true"
        },
        method="GET"
)

    try:
        with _http.open(request, timeout=5) as response:
            if response.status != 200:
                raise SmokeTestFailure(f'{path}: expected HTTP 200, got {response.status}')
            if response.headers.get_content_type() != 'application/json':
                raise SmokeTestFailure(f'{path}: response is not JSON')
            return json.load(response)
    except (HTTPError, URLError, TimeoutError, ValueError) as exc:
        raise SmokeTestFailure(f'{path}: {exc}') from exc


def check(condition: bool, description: str):
    if not condition:
        raise SmokeTestFailure(description)


def run_smoke_tests(base_url: str):
    # GET /health/ checks Django and its PostgreSQL connection.
    health = get_json(base_url, '/health/')
    check(isinstance(health, dict) and health.get('status') == 'OK',
          '/health/: expected {"status": "OK"}')
    logger.info('PASS /health/')

    # GET /api/movies/ checks the public catalog and its pagination.
    catalog = get_json(base_url, '/api/movies/')
    check(isinstance(catalog, dict), '/api/movies/: expected an object')
    check(isinstance(catalog.get('count'), int), '/api/movies/: missing count')
    movies = catalog.get('results')
    check(isinstance(movies, list), '/api/movies/: missing results list')
    logger.info('PASS /api/movies/')

    # A real movie, if present, exercises the detail serializer and DB relations.
    if movies:
        movie = movies[0]
        check(isinstance(movie, dict) and isinstance(movie.get('id'), int),
              '/api/movies/: first movie has no integer id')
        check(isinstance(movie.get('title'), str) and bool(movie['title']),
              '/api/movies/: first movie has no title')
        detail = get_json(base_url, f"/api/movies/{movie['id']}/")
        check(isinstance(detail, dict) and detail.get('id') == movie['id'],
              '/api/movies/<id>/: unexpected movie detail')
        check(isinstance(detail.get('genres'), list),
              '/api/movies/<id>/: genres must be a list')
        logger.info('PASS /api/movies/%s/', movie['id'])
    else:
        logger.info('SKIP movie detail: catalog is empty')

    # GET /api/genres/ is a public, non-paginated endpoint.
    genres = get_json(base_url, '/api/genres/')
    check(isinstance(genres, list), '/api/genres/: expected a list')
    logger.info('PASS /api/genres/')

    # GET /api/comments/ is read-only and works without authentication.
    comments = get_json(base_url, '/api/comments/')
    check(isinstance(comments, dict) and isinstance(comments.get('results'), list),
          '/api/comments/: expected paginated results')
    logger.info('PASS /api/comments/')

    # GET /api/config/images/ checks the frontend image configuration API.
    config = get_json(base_url, '/api/config/images/')
    check(isinstance(config, dict), '/api/config/images/: expected an object')
    check(isinstance(config.get('base_url'), str) and bool(config['base_url']),
          '/api/config/images/: invalid base_url')
    for key in ('poster_sizes', 'backdrop_sizes', 'profile_sizes'):
        check(isinstance(config.get(key), list) and bool(config[key]),
              f'/api/config/images/: invalid {key}')
    logger.info('PASS /api/config/images/')


def lambda_handler(event, context):
    try:
        check(event.get('lifecycleStage') == 'PRE_PRODUCTION_TRAFFIC_SHIFT',
              'Unexpected ECS lifecycle stage')

        base_url = os.environ['SMOKE_TEST_BASE_URL'].strip()
        parsed = urlsplit(base_url)
        check(parsed.scheme in ('http', 'https') and bool(parsed.netloc),
              'SMOKE_TEST_BASE_URL must be a valid HTTP(S) test endpoint')

        run_smoke_tests(base_url)
        logger.info('All Cinebase smoke tests passed')
        return {'hookStatus': 'SUCCEEDED'}
    except Exception:
        logger.exception('Cinebase smoke tests failed')
        return {'hookStatus': 'FAILED'}
