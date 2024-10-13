"""Test the infrastructure status of the Avro Tools image."""
import testinfra_bdd
from pytest_bdd import scenarios

scenarios('../features/')


# Ensure that the PyTest fixtures provided in testinfra-bdd are available to
# your test suite.
pytest_plugins = testinfra_bdd.PYTEST_MODULES
