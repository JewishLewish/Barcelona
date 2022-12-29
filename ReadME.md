```Rust
fn main {
    echo "Hello world";
    record "Test" -> "Hello world";

    fetch "Test" -> x;

    if x == "Hello world" {
        echo "This works!";
    }

    x = "test";
    garbage x;

    test();

}

/*Comments are anything THAT ARE NOT INSIDE THE FUNCTIONS!*/

fn test {
    echo "Hello world";
}


main();

echo "DONE!";
```