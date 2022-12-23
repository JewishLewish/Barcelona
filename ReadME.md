```Rust
fn main {
    echo "Hello world";
    record "Test" -> "Hello world";
    echo fetch("Test");

    if fetch("Test") == "Hello world" {
        echo "test";
    };

    var x = "test";
    garbage(x);

    test();

}

/*Comments are anything THAT ARE NOT INSIDE THE FUNCTIONS!*/

fn test {
    echo "Hello world";
}
```