"""
Applet: ESB NYC Colors
Summary: Empire State Bld Colors
Description: Shows today's colors of the Empire State Building.
Author: sklose
"""

load("http.star", "http")
load("render.star", "render")

def main():
    rep = http.get("https://lzxe5agehadtlh2kaecrlk62c40dimdp.lambda-url.us-east-1.on.aws/", ttl_seconds = 3600)
    if rep.status_code != 200:
        fail("request failed with status %d", rep.status_code)

    json = rep.json()
    description = json["description"]
    color1 = json["colors"][0]
    color2 = json["colors"][0]
    color3 = json["colors"][0]

    if len(json["colors"]) > 1:
        color2 = json["colors"][1]
        color3 = json["colors"][1]

    if len(json["colors"]) > 2:
        color3 = json["colors"][2]

    colorMap = {
        "blue": "#00f",
        "red": "#f00",
        "green": "#0f0",
        "white": "#fff",
        "yellow": "#ff9",
        "purple": "#808",
        "pink": "#f0b",
        "orange": "#fa0",
        "brown": "#a22",
        "gold": "#fd0",
        "teal": "#088",
    }

    return render.Root(
        delay = 100,
        child = render.Stack(
            children = [
                render.Row(
                    children = [
                        render.Column(
                            cross_align = "center",
                            children = [
                                render.Box(width = 2, height = 12, color = colorMap[color1]),
                                render.Box(width = 4, height = 2, color = colorMap[color1]),
                                render.Box(width = 12, height = 12, color = colorMap[color2]),
                                render.Box(width = 14, height = 6, color = colorMap[color3]),
                            ],
                        ),
                        render.Column(
                            children = [
                                render.Padding(
                                    pad = (1, 0, 0, 0),
                                    child = render.Marquee(
                                        height = 32,
                                        scroll_direction = "vertical",
                                        child = render.WrappedText(
                                            content = description,
                                            width = 50,
                                            font = "tom-thumb",
                                        ),
                                    ),
                                ),
                            ],
                        ),
                    ],
                ),
            ],
        ),
    )
