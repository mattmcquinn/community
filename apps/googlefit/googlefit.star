"""
Applet: GoogleFit
Summary: Daily step count
Description: Daily step count from Google Fit.
Author: mattmcquinn
"""

load("render.star", "render")
load("schema.star", "schema")
load("encoding/json.star", "json")
load("http.star", "http")

GOOGLE_CLIENT_SECRET = secret.decrypt("")
GOOGLE_CLIENT_ID = secret.decrypt("")

def main(config):
    return render.Root(
        child = render.Text("foo"),
    )

def oauth_handler(params):
    # deserialize oauth2 parameters, see example above.
    params = json.decode(params)
    print(params)
    res = http.post(url="https://oauth2.googleapis.com/token",
        headers={"Content-type": "application/x-www-form-urlencoded"},
        body="code=" + params["code"] + "&client_id=" + params["client_id"] + "&redirect_uri=" +
        params["redirect_uri"] + "&grant_type=" + params["grant_type"] + "&client_secret=" + "")

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
        fields=[
            schema.OAuth2(
                id="auth",
                name="Google",
                desc="Connect your Google account.",
                icon="google",
                handler=oauth_handler,
                client_id="916660171917-34mkku3vh93dole6cigtb6jak3tjedns.apps.googleusercontent.com",
                authorization_endpoint="https://accounts.google.com/o/oauth2/auth",
                scopes=[
                    "https://www.googleapis.com/auth/fitness.activity.read",
                ],
            )

        ]
    )
