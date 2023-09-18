FROM python:3.10


# download the model files
RUN mkdir -p /root/.cache/voicefixer/analysis_module/checkpoints
RUN curl "https://zenodo.org/record/5600188/files/vf.ckpt?download=1" > \
         /root/.cache/voicefixer/analysis_module/checkpoints/vf.ckpt

RUN mkdir -p /root/.cache/voicefixer/synthesis_module/44100
RUN curl 'https://zenodo.org/record/5469951/files/model.ckpt-1490000_trimed.pt?download=1' > \
         /root/.cache/voicefixer/synthesis_module/44100/model.ckpt-1490000_trimed.pt


# install the app and lock down the requirements
WORKDIR /tmp
ADD requirements.txt /tmp/
RUN git clone https://github.com/haoheliu/voicefixer.git && \
    cd /tmp/voicefixer && \
    git checkout 2e44f101&& \
    pip install /tmp/voicefixer --no-cache-dir && \
    pip install --no-cache-dir --no-deps -r /tmp/requirements.txt && \
    rm -rf /tmp/voicefixer /tmp/requirements.txt

# fix api change bug
ADD stft.py /usr/local/lib/python3.10/site-packages/torchlibrosa/stft.py

# pwd will be mapped to here
RUN mkdir /data
WORKDIR /data

# ensure that the current user can create/access files in config and cache
RUN mkdir /root/.config && \
    ln -s /root/.cache /.cache && \
    ln -s /root/.config /.config && \
    chmod --recursive 777 /root && \
    chmod 777 /.cache && \
    chmod 777 /.config

# pwd is here
WORKDIR /data
