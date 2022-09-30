from setuptools import find_packages, setup

if __name__ == "__main__":
    setup(
        name="paretos_project",
        packages=find_packages(exclude=["paretos_project_tests"]),
        install_requires=[
            "dagster",
            "pytest",
        ],
        extras_require={"dev": ["dagit", "pytest"]},
    )
