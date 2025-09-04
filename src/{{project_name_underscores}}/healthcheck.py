#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""Health Check

This script does a health check on our app, specifically checking for a 200
status and the text "UP" in the response body. There are a number of reasons why
we're doing that health check here rather than in a `curl` command, many of
which are covered here:

https://web.archive.org/web/20220912181723/https://blog.sixeyed.com/docker-healthchecks-why-not-to-use-curl-or-iwr/

Our primary reason is that we don't want `curl` on the production image.
Similarly, we don't use any external libraries, such as request, in this script
so that everything is self-contained.
"""

import argparse
import sys
from urllib.error import URLError
from urllib.request import urlopen


def init_argparse() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="healthcheck",
        usage="%(prog)s [OPTIONS]",
        description="Check the API health endpoint to verify it is up.",
        argument_default=argparse.SUPPRESS,
    )
    parser.add_argument(
        "-p",
        "--port",
        action="store",
        type=str,
        default="80",
        help="the port to check",
    )
    parser.add_argument(
        "--host",
        action="store",
        type=str,
        default="localhost",
        help="the host to check",
    )
    parser.add_argument(
        "-t",
        "--timeout",
        action="store",
        type=float,
        default=0.5,
        help="timeout, in secs, on the check",
    )
    return parser


def main() -> int:
    parser = init_argparse()
    args = parser.parse_args()
    ok_status = 200
    try:
        with urlopen(  # noqa: S310
            f"http://{args.host}:{args.port}/health", timeout=args.timeout
        ) as response:
            if response.status == ok_status and response.read().decode("utf8") == "UP":
                print("SUCCESS: App is healthy")
                return 0
            else:
                print("WARNING: App is unhealthy")
                return 1
    except URLError as error:
        print(f"ERROR: Error during health request: {error}")
        return 2
    except TimeoutError as error:
        print(f"ERROR: Timeout during health request: {error}")
        return 3


if __name__ == "__main__":
    sys.exit(main())
