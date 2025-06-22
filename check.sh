pre-commit clean > /dev/null                           
pre-commit install --install-hooks > /dev/null         
pre-commit run --all-files || true                     
