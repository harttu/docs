# go to main folder
cd /data
# upgrade pip
python -m pip install --user --upgrade pip
# check the version, should point to home dir
python -m pip --version
# venv should be installed by default
python -m venv transformers_env
# go to new env
source transformers_env/bin/activate
# check that python points to current env
which python
# install torch
python -m pip install torch torchvision torchaudio
# install transformers
python -m pip install transformers
# intall jupyter
python -m pip install jupyterlab
# run jupyter 
jupyter-lab --no-browser --port=1234
