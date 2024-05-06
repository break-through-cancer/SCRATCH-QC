#!/usr/bin/env python3

from cirro.helpers.preprocess_dataset import PreprocessDataset
import pandas as pd
import os

def adding_modality(ds: PreprocessDataset) -> pd.DataFrame:
    
    # Make a wide sample_table
    ds.logger.info("Pivoting samplehsheet:")

    # Can I check if has modality column?
    sample_table = ds.wide_samplesheet(
        index=["sampleIndex", "sample", "lane"],
        columns="read",
        values="file",
        column_prefix="fastq_"
    ).sort_values(
        by="sample"
    )

    # How can I read the metadata? Is it ds.samplesheet?
    ds.logger.info("Adding modality column from:")
    sample_table = sample_table.merge(ds.samplesheet)

    ds.logger.info(sample_table.to_csv(index=None))

    return sample_table

def setup_input_parameters(ds: PreprocessDataset):

    # Adding new samplesheet including modality
    if ds.params.get("samplesheet") is None:
        ds.add_param(
            "samplesheet",
            "sample_table.csv"
        )

if __name__ == "__main__":

    ds = PreprocessDataset.from_running()

    ds.logger.info("Exported paths:")
    ds.logger.info(os.environ['PATH'])

    ds.logger.info("Files annotated in the dataset:")
    ds.logger.info(ds.files)

    ds.logger.info("Checking metadata:")
    ds.logger.info(ds.samplesheet.columns)
    ds.logger.info(ds.samplesheet)

    # Make a sample table of the input data
    sample_table = adding_modality(ds)
    sample_table.to_csv("sample_table.csv", index=None)

    setup_input_parameters(ds)

    ds.logger.info("Printing out parameters:")
    ds.logger.info(ds.params)
