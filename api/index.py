import sys
import os

# Add the backend app folder to sys.path so it can resolve local imports like 'routes', 'core', 'models' etc.
app_path = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "lib", "backend", "app"))
sys.path.append(app_path)

from main import app
