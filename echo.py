from flask import Flask, jsonify, request


app = Flask(__name__)

@app.route('/')
def index():
    echo = request.args.get('echo')
    return jsonify(echo=echo)


if __name__ == '__main__':
    app.run(port=1234)
