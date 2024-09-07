from setuptools import setup, find_packages

setup(
    name="py-behave-gcp",
    version="0.1",
    packages=find_packages(),
    install_requires=["behave", "fastapi"],
    entry_points={
        "console_scripts": ["py-behave-gcp=py-behave-gcp.cli:main"]
    },
)
