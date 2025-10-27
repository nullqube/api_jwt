```markdown
# `rails tokens:cleanup`

Cleans up expired refresh tokens from the database.  
This task should be scheduled to run periodically (e.g., daily) to prevent the database from growing indefinitely with expired tokens.  
It leverages the `RefreshToken` model's `cleanup_expired!` method.

> **Note:** Make sure to test this task in a safe environment before deploying it to production.

## Usage

Add to your cron jobs or scheduling system to run as needed.

### Example cron entry (runs daily at midnight):

```sh
crontab -e
```

```cron
# Run cleanup daily at 2:30 AM
30 2 * * * cd /path/to/your/rails/app && bundle exec rake tokens:cleanup >> log/cleanup_tokens.log 2>&1
```
or

```cron
0 0 * * * /bin/bash -l -c 'cd /path/to/your/app && RAILS_ENV=production bundle exec rails tokens:cleanup'
```

### Use a wrapper script

Create a script:

```bash
#!/bin/bash
cd /path/to/your/rails/app
RAILS_ENV=production bundle exec rake tokens:cleanup
```
Then schedule the wrapper script in cron:

```cron
30 2 * * * /path/to/your/wrapper_script.sh >> /path/to/your/rails/app/log/cleanup_tokens.log 2>&1
```
Make sure the script has execute permissions:

```sh
chmod +x /path/to/your/wrapper_script.sh
```

---

## Use systemd timer (alternative to cron)

### `/etc/systemd/system/app-tokens-cleanup.service`

```ini
[Unit]
Description=Clean up expired refresh tokens for MyApp
After=network.target

[Service]
Type=oneshot
User=deploy                     # 👈 Replace with your app user
WorkingDirectory=/var/www/myapp # 👈 Replace with your Rails root
Environment=RAILS_ENV=production
ExecStart=/usr/local/bin/bundle exec rake tokens:cleanup
StandardOutput=journal
StandardError=journal
```

### `/etc/systemd/system/app-tokens-cleanup.timer`

```ini
[Unit]
Description=Run token cleanup daily
Requires=app-tokens-cleanup.service

[Timer]
# 🌍 To run at 2:30 AM local time, use:
# OnCalendar=*-*-* 02:30:00
OnCalendar=daily
Persistent=true

[Install]
WantedBy=timers.target
```

### ▶️ How to Deploy & Enable
Run these commands on your server:

```sh
# Reload systemd to detect new files
sudo systemctl daemon-reload
# Enable the timer (so it starts on boot)
sudo systemctl enable --now app-tokens-cleanup.timer
# Verify it's active
systemctl list-timers | grep tokens
```

> **Note:** If your service/timer is named differently (e.g., `cleanup_tokens.timer`), adjust accordingly:

```sh
# Enable and start the timer:
sudo systemctl enable cleanup_tokens.timer
sudo systemctl start cleanup_tokens.timer
# Check status:
sudo systemctl status cleanup_tokens.timer
# Check logs:
# See last run output
journalctl -u app-tokens-cleanup.service -n 20
# Follow logs in real time (if running now)
journalctl -u app-tokens-cleanup.service -f
```
---

# `rails tokens:stats`

Displays statistics about refresh tokens in the database.  
This task provides insights into the number of total, active, expired, and revoked refresh tokens. It is useful for monitoring token usage.

## Revoke all tokens for a user by email:

```sh
rails "tokens:revoke_user[user@example.com]"
```