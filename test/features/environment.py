import logging
import os
import warnings
from datetime import datetime
from time import strftime

from behave.contrib.scenario_autoretry import patch_scenario_with_autoretry


def before_all(context):  # noqa
    warnings.filterwarnings("ignore", category=UserWarning)

    # Logging settings
    log_file = f'test_run_results_{datetime.now().strftime("%Y-%m-%d")}.log'
    logging.basicConfig(filename=log_file, level=logging.INFO, filemode='w',
                        format='%(asctime)s - %(levelname)s - %(message)s', datefmt='%Y-%m-%d %H:%M:%S')
    context.logger = logging.getLogger(__name__)

    context.logger.info("# =========================================================================================")
    context.logger.info("# TESTING STARTED AT : " + strftime("%Y-%m-%d %H:%M:%S"))
    context.logger.info("# =========================================================================================\n")


def before_feature(context, feature):
    context.logger.info("# =========================================================================================")
    context.logger.info(f"# Starting the feature: {feature.name}")
    context.logger.info("# =========================================================================================\n")

    for scenario in feature.scenarios:
        if "test_template" in scenario.effective_tags:
            patch_scenario_with_autoretry(scenario, max_attempts=1)


def before_scenario(context, scenario):  # noqa
    context.logger.info("# =========================================================================================")
    context.logger.info(f"# Starting the scenario: {scenario.name}")
    context.logger.info("# =========================================================================================")

    patch_scenario_with_autoretry(scenario, max_attempts=1)


def after_scenario(context, scenario):  # noqa
    context.logger.info("# =========================================================================================")
    context.logger.info(f"# Finalizing the scenario: {scenario.name}")
    context.logger.info("# =========================================================================================\n")


def before_step(context, step):
    context.logger.info(f"Executing Step: {step.name}")


def after_all(context):  # noqa
    context.logger.info("# =========================================================================================")
    context.logger.info("# TESTING FINISHED AT : " + strftime("%Y-%m-%d %H:%M:%S"))
    context.logger.info("# =========================================================================================")
