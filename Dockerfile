FROM python:3

COPY generate_icon.py /
RUN python3 -m pip install --upgrade pip \
 && python3 -m pip install --upgrade Pillow \
 && chmod +x /generate_icon.py
CMD [ "/generate_icon.py" ]
