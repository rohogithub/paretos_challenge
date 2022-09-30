from dagster_dbt import dbt_cli_resource, load_assets_from_dbt_project
from dagster import  IOManager, io_manager
from dagster import ScheduleDefinition,  define_asset_job, repository,  with_resources
from dagster import RunRequest, sensor, schedule
import os

# class LocalParquetIOManager(IOManager):
#     def _get_path(self, context):
#         return os.path.join(context.run_id, context.step_key, context.name)
#
#     def handle_output(self, context, obj):
#         obj.write.parquet(self._get_path(context))
#
# @io_manager
# def local_parquet_io_manager():
#     return LocalParquetIOManager()


DBT_PROJECT_PATH = "paretos_project/assets/dbt_toy"
dbt_assets = with_resources(
    load_assets_from_dbt_project(DBT_PROJECT_PATH),
    resource_defs={
        # "io_manager": local_parquet_io_manager,
        "dbt": dbt_cli_resource.configured(
            {"project_dir": DBT_PROJECT_PATH,}
        ),
    },
)


run_everything_job = define_asset_job("run_everything", selection="*")

@schedule(cron_schedule="0 10 * * *", job=run_everything_job, execution_timezone="US/Central")
def etl_job_schedule(_context):
    run_config = {}
    return run_config

@sensor(job=run_everything_job)
def my_sensor():
    should_run = True
    if should_run:
        yield RunRequest(run_key=None, run_config={})

@repository
def my_repository():
    jobs = [dbt_assets]
    schedules = [etl_job_schedule]
    sensors = [my_sensor]
    return jobs + schedules + sensors

