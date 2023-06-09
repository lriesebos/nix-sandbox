use clap::Parser;

/// Greeting application written in Rust
#[derive(Parser)]
#[command(version)]
struct Cli {
    /// Who to greet
    name: Option<String>,
}

fn main() {
    let cli = Cli::parse();
    println!("Hello, {}!", cli.name.unwrap_or(String::from("world")));
    println!("I'm a Rustacean!");
}
