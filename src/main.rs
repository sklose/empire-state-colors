use lambda_http::{run, service_fn, Body, Error, Request, Response};
use regex::RegexBuilder;
use reqwest::ClientBuilder;
use visdom::Vis;

#[derive(serde::Serialize)]
struct LambdaResponse {
    pub colors: Vec<String>,
    pub description: String,
}

async fn function_handler(_: Request) -> Result<Response<Body>, Error> {
    let client = ClientBuilder::new().build().unwrap();
    let resp = client
        .get("https://www.esbnyc.com/about/tower-lights")
        .send()
        .await
        .unwrap();
    let body = resp.text().await.unwrap();

    let root = Vis::load(&body).unwrap();
    let color_text = root.find(".is-today h3").text();
    let mut description = root.find(".is-today .field_description p").text();
    if description.is_empty() {
        description = root.find(".is-today .info h3").text();
    }

    let color_regex =
        RegexBuilder::new("(green|white|blue|yellow|purple|pink|orange|brown|gold|red|teal)")
            .case_insensitive(true)
            .build()
            .unwrap();

    let colors: Vec<_> = color_regex
        .find_iter(&color_text)
        .map(|v| v.as_str().to_lowercase())
        .collect();

    let body = serde_json::json!({
        "colors": colors,
        "description": description
    });

    let resp = Response::builder()
        .status(200)
        .header("content-type", "application/json")
        .body(body.to_string().into())
        .map_err(Box::new)?;
    Ok(resp)
}

#[tokio::main]
async fn main() -> Result<(), Error> {
    tracing_subscriber::fmt()
        .with_max_level(tracing::Level::INFO)
        .with_target(false)
        .without_time()
        .init();

    run(service_fn(function_handler)).await
}
