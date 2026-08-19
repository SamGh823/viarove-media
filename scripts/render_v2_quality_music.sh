#!/usr/bin/env bash
set -euo pipefail
mkdir -p /tmp/viarove media
cat chunks/VIAROVE_TEST_FRAME.jpg.part* | tr -d '\n\r' | base64 -d > /tmp/viarove/frame.jpg

ffmpeg -y -f lavfi -i "aevalsrc=0.12*sin(2*PI*110*t)+0.08*sin(2*PI*220*t)+0.055*sin(2*PI*261.63*t)+0.045*sin(2*PI*329.63*t):s=48000:d=8" \
  -af "pan=stereo|c0=c0|c1=c0,highpass=f=55,lowpass=f=9000,aecho=0.8:0.7:280|560:0.20|0.10,afade=t=in:st=0:d=1.1,afade=t=out:st=6.7:d=1.3,loudnorm=I=-14:TP=-1.5:LRA=7" \
  -c:a aac -b:a 192k /tmp/viarove/music.m4a

ffmpeg -y -loop 1 -i /tmp/viarove/frame.jpg -i /tmp/viarove/music.m4a -t 8 \
  -vf "scale=1160:2062:flags=lanczos,zoompan=z='min(zoom+0.00045,1.035)':x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':d=240:s=1080x1920:fps=30,eq=contrast=1.045:saturation=1.06:brightness=-0.01,drawtext=fontfile=/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf:text='Some roads are meant':fontcolor=white:fontsize=52:borderw=2:bordercolor=black@0.65:x=(w-text_w)/2:y=620,drawtext=fontfile=/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf:text='to be driven alone.':fontcolor=white:fontsize=52:borderw=2:bordercolor=black@0.65:x=(w-text_w)/2:y=685,drawtext=fontfile=/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf:text='VIAROVE':fontcolor=white:fontsize=30:borderw=1:bordercolor=black@0.6:x=(w-text_w)/2:y=h-190,format=yuv420p" \
  -r 30 -c:v libx264 -preset slow -crf 16 -profile:v high -level 4.1 \
  -c:a aac -b:a 192k -ar 48000 -movflags +faststart \
  media/VIAROVE_V2_QUALITY_MUSIC_TEST.mp4

ffprobe -v error -show_entries format=duration,size,bit_rate -show_entries stream=codec_name,width,height,r_frame_rate,bit_rate -of json media/VIAROVE_V2_QUALITY_MUSIC_TEST.mp4
