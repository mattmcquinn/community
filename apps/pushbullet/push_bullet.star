"""
Applet: Push Bullet
Summary: Sync with Push Bullet
Description: Sync notifications with Push Bullet.
Author: mattmcquinn
"""

load("render.star", "render")
load("schema.star", "schema")
load("encoding/json.star", "json")
load("http.star", "http")
load("cache.star", "cache")
load("secret.star", "secret")

CLIENT_ID = "lf5dQQnzbWlCVIs65HYv29XgVBZNfOa9"
ENC_CLIENT_SECRET = "AV6+xWcEExLjQ371WulX9uSq4LxIKrqXC/ZKVGpJ4oLJGUzi+Ta1uGgL1y9FDTLnihMYP+Tu0g47jBnUYkT5FrvyhCE8xpbCV+sc2IbC0bEU/N+oI3dFb48tSjtGJG9+97wSXXrNsJfHfmHq8LIfcFUiYeHTzg5utNJf9fO/trhpLXZKxfg="

def main(config):
    cache.set("ACCESS_TOKEN", config.get("access-token", ""), 1800)
    token = config.get("auth")

    if token:
        user = get_current_user(token)
        msg = user
    else:
        msg = "Unauthenticated"
    return render.Root(
        child = render.Text(msg),
    )

def get_current_user(token):
    resp = http.get(
        url = "https://api.pushbullet.com/v2/users/me",
        headers = {
            "Access-Token": token,
        },
    )

    if resp.status_code != 200:
        fail("current user request failed with status code: %d - %s" %
             (resp.status_code, resp.body()))

    user_json = resp.json()
    name = user_json["name"]
    print(name)

    return name

def oauth_handler(params):
    params = json.decode(params)
    auth_code = params.get("code")
    return get_access_token(auth_code)

def get_access_token(auth_code):
    json_body = {
        "code": auth_code,
        "client_secret": secret.decrypt(ENC_CLIENT_SECRET),
        "grant_type": "authorization_code",
        "client_id": CLIENT_ID,
    }

    res = http.post(
        url = "https://api.pushbullet.com/oauth2/token",
        headers = {
            "Content-Type": "application/json",
            "Access-Token": cache.get("ACCESS_TOKEN"),
        },
        json_body = json_body,
    )
    if res.status_code != 200:
        fail("token request failed with status code: %d - %s" %
             (res.status_code, res.body()))

    token_params = res.json()
    access_token = token_params["access_token"]
    print(access_token)

    return access_token

def get_schema():
    return schema.Schema(
        version = "1",
        fields = [
            schema.OAuth2(
                id = "auth",
                name = "Push Bullet Login",
                desc = "Connect to your Push Bullet account",
                icon = "user",
                client_id = CLIENT_ID,
                handler = oauth_handler,
                authorization_endpoint = "https://www.pushbullet.com/authorize?redirect_uri=http%3A%2F%2Flocalhost:8080/",
                scopes = [""],
            ),
            schema.Text(
                id = "access-token",
                name = "Access Token",
                desc = "Push Bullet Access Token",
                icon = "token",
            ),
        ],
    )
