# Halloween USB Loop

A Roku developer channel that plays every video on a USB drive in an endless loop. Built for the Roku 3 (model 4200X) and works on other Roku devices with a USB port.

## Downloads

Download both files (no GitHub account needed):

- **[HalloweenUSBLoop.zip](https://github.com/jcphilly/halloween-usb-loop/raw/main/downloads/HalloweenUSBLoop.zip)**
- **[01-usb-test.mp4](https://github.com/jcphilly/halloween-usb-loop/raw/main/downloads/01-usb-test.mp4)**


| File | What it is | Where it goes |
|---|---|---|
| `HalloweenUSBLoop.zip` | The Roku channel | Upload to the Roku. **Do not unzip it.** |
| `01-usb-test.mp4` | 15-second test video that says "Playing from USB" | Root of the USB drive |

## Prepare the USB drive

- Format as FAT32 (or exFAT/NTFS for files over 4 GB).
- Use `.mp4` files with H.264 video and AAC audio, 1080p or lower. The Roku 3 can't play HEVC/H.265.
- Files play in alphabetical order. Prefix names to set the order: `01-ghosts.mp4`, `02-skeletons.mp4`.

## Install on the Roku

1. Remove any microSD card from the Roku. Developer channels fail to install when a card is inserted.
2. On the physical remote, press **Home ×3, Up ×2, Right, Left, Right, Left, Right** within 10 seconds. Accept the agreement, enable the installer, set a password, and note the IP address.
3. On a computer on the same network, open `http://<roku-ip>`. Sign in as `rokudev` with that password.
4. Click **Upload**, choose `HalloweenUSBLoop.zip` exactly as downloaded, and click **Install**.
5. Plug in the USB drive. The screen shows **"Playing from USB."** If it shows **"Built-in test clip,"** the Roku found no playable videos.

### "No manifest" error

The zip was unzipped and re-zipped, so its contents now sit inside a folder. Download it again and upload the `.zip` without opening it. On a Mac, turn off **Safari › Settings › General › Open "safe" files after downloading** first.

## Start the loop after power-on

The Roku always boots to its home screen. Pick one:

| Method | Hands-off? | How |
|---|---|---|
| Screensaver | Test it | Settings › Theme › Screensavers › **Halloween USB Loop**, wait time **1 minute**. |
| Network launch | Yes | An always-on device on the same Wi-Fi runs the script below after power-on. |
| Remote | No | Open **Halloween USB Loop** from the home screen each night. |

```bash
ROKU=192.168.1.50   # set to the Roku's IP
for i in $(seq 1 30); do
  if curl -s -m 3 "http://$ROKU:8060/query/active-app" | grep -q 'id="dev"'; then
    echo "Loop is running"; break
  fi
  curl -s -m 3 -d '' "http://$ROKU:8060/launch/dev" >/dev/null
  sleep 10
done
```

## Outdoors

Use a GFCI outlet and outdoor-rated cords. Keep the Roku and power strip in a covered box off the ground.
