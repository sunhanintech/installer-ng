import sys
from yolk import cli


if __name__ == '__main__':
    out = sys.argv[1]
    sys.argv = [sys.argv[0], "-l", "-f", "license"]
    with open(out, 'w') as f:
        sys.stdout = f
        cli.main()
