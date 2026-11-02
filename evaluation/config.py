from __future__ import annotations

from dataclasses import dataclass, field
from pathlib import Path

import yaml

DEFAULT_CONFIG_FILE = Path(__file__).parent / "config.yaml"


@dataclass
class Config:
    """
    Configuration of a model evaluation.

    Parameters
    ----------
    model : str
        Name of the model. It must match the directory `data/<model>`.
    domains : list[str]
        Domains to evaluate.
    experiments : list[str]
        Training experiments to evaluate.
    variables : list[str]
        Variables to evaluate.
    """

    model: str
    domains: list[str] = field(default_factory=lambda: ["ALPS", "NZ", "SA"])
    experiments: list[str] = field(
        default_factory=lambda: ["ESD_pseudo_reality", "Emulator_hist_future"]
    )
    variables: list[str] = field(default_factory=lambda: ["tasmax", "pr"])

    @classmethod
    def from_yaml(cls, path: str | Path = DEFAULT_CONFIG_FILE) -> Config:
        """
        Read the configuration from a YAML file.

        Attributes that are missing or empty in the file take their default
        values, except for `model`, which is compulsory.

        Parameters
        ----------
        path : str | Path
            YAML configuration file. By default, `config.yaml` next to this module.

        Returns
        -------
        Config
            Configuration read from the file.

        Raises
        ------
        ValueError
            If `model` is not defined in the file.
        TypeError
            If the file contains an unknown attribute.
        """
        with open(path) as f:
            settings = yaml.safe_load(f) or {}

        # a key whose items are all commented out is read by YAML as None
        settings = {key: value for key, value in settings.items() if value is not None}

        if "model" not in settings:
            raise ValueError(f"The attribute 'model' is compulsory in {path}")

        return cls(**settings)
