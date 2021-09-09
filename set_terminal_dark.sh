#!/bin/sh

path=/mlsteam/.jupyter/lab/user-settings/@jupyterlab/terminal-extension

mkdir -m 755 -p $path
cat <<EOT > $path/plugin.jupyterlab-settings
{
    // Terminal
    // @jupyterlab/terminal-extension:plugin
    // Terminal settings.
    // *************************************

    // Theme
    // The theme for the terminal.
    "theme": "dark"
}
EOT
