from fastapi import FastAPI

app = FastAPI()


@app.get('/')
def greet():
    return "How are you my friend.Welcome back to FastApi"