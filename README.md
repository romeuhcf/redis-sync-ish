# redis-sync

A simple script to sync data from one Redis instance to another.

## Features

-   Syncs string data between Redis instances.
-   Uses SCAN for efficient key iteration.
-   Filters keys based on provided patterns.
-   Supports one-time and looping sync modes.
-   Preserves TTL (Time To Live) values.
-   Multi-threaded for concurrent syncing of multiple patterns.

## Requirements

-   Ruby 2.7 or higher
-   Bundler
-   Redis gem

## Installation

1.  Clone the repository:

    ```bash
    git clone https://github.com/your-username/redis-sync.git
    cd redis-sync
    ```
2.  Install dependencies:

    ```bash
    bundle install
    ```

## Usage

```bash
./redis-sync.rb (once | loop) <source_redis_url> <destination_redis_url> <pattern1> <pattern2> ...
```

-   `once`: Syncs the data once and exits.
-   `loop`: Syncs the data in a loop, continuously migrating new keys.
-   `<source_redis_url>`: URL of the source Redis instance (e.g., `redis://localhost:6379`).
-   `<destination_redis_url>`: URL of the destination Redis instance.
-   `<pattern1> <pattern2> ...`: One or more key patterns to filter the keys to be synced (e.g., `user:*`, `session:*`).

### Examples

Sync keys matching `user:*` once:

```bash
./redis-sync.rb once redis://localhost:6379 redis://localhost:6380 user:*
```

Sync keys matching `session:*` and `cache:*` in a loop:

```bash
./redis-sync.rb loop redis://localhost:6379 redis://localhost:6380 session:* cache:*
```

### Debugging

Set the `DEBUG` environment variable to enable debug output:

```bash
DEBUG=1 ./redis-sync.rb once redis://localhost:6379 redis://localhost:6380 user:*
```

## Contributing

Feel free to contribute by submitting issues and pull requests.

## License

MIT
