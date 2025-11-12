# Public Files

This directory contains publicly accessible files for seewaan.com:

## Files

- **favicon.ico**: Site favicon (to be added)
- **.well-known/nostr.json**: Nostr NIP-05 identifier configuration

## Usage

These files are mounted as a volume in the Docker container and served by nginx through the Seewaan service.

### Adding the Favicon

Place your favicon.ico file in this directory:
```bash
cp /path/to/your/favicon.ico public/favicon.ico
```

### Configuring Nostr NIP-05

Edit `.well-known/nostr.json` to add your Nostr identifiers:
```json
{
  "names": {
    "username": "npub1..."
  },
  "relays": {
    "npub1...": ["wss://relay.example.com"]
  }
}
```
