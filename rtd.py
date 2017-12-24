from os.path import abspath, join, dirname
from readthedocs_build.build import build

print(join(dirname(abspath(__file__)), 'doc'))

build([{
    'output_base': abspath('outdir'),
    'name': 'docs',
    'type': 'sphinx',
    'base': '/src/doc',
}])
