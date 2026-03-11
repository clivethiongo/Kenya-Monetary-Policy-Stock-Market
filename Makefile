install:
	pip install -r requirements.txt

run:
	jupyter notebook

clean:
	rm -rf __pycache__
	rm -rf .ipynb_checkpoints

make install:
	pip install -r requirements.txt

make run:
	jupyter notebook
	