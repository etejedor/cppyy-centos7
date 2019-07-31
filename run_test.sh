eval "$(pyenv init -)"

echo "--- Running test with system Python (2.7.5)"
pyenv global system
python test.py

export PYTHONPATH=/usr/lib/python2.7/site-packages/:$PYTHONPATH

echo "--- Running test with Python 2.7.13"
pyenv global 2.7.13
python test.py

echo "--- Running test with Python 2.7.14"
pyenv global 2.7.14
python test.py

