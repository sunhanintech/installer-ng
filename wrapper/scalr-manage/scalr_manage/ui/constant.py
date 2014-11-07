# coding:utf-8
import re


EMAIL_RE = re.compile(r"[^@]+@[^@]+\.[^@]+")

OPENSSL_START_KEY = "-----BEGIN RSA PRIVATE KEY-----"
OPENSSL_END_KEY = "-----END RSA PRIVATE KEY-----"
OPENSSL_PROC_TYPE = "Proc-Type: "
OPENSSL_ENCRYPTED = "ENCRYPTED"
