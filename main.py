import sys
import os
from dotenv import load_dotenv

# Add the backend app folder to sys.path so it can resolve local imports like 'routes', 'core', 'models' etc.
app_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), "lib", "backend", "app"))
sys.path.append(app_dir)

# Load env variables from the app folder if present (useful for local development run from root)
env_path = os.path.join(app_dir, ".env")
if os.path.exists(env_path):
    load_dotenv(env_path)

# Dynamically load the backend main.py to avoid circular import conflicts with this file's name (main.py)
import importlib.util
spec = importlib.util.spec_from_file_location("backend_main", os.path.join(app_dir, "main.py"))
backend_main = importlib.util.module_from_spec(spec)
sys.modules["backend_main"] = backend_main
spec.loader.exec_module(backend_main)

app = backend_main.app
