# coding:utf-8
import re


EMAIL_RE = re.compile(r"[^@]+@[^@]+\.[^@]+")

OPENSSL_START_KEY_RE = re.compile("^-----BEGIN (RSA|DSA) PRIVATE KEY-----$")
OPENSSL_END_KEY_RE = re.compile("^-----END (RSA|DSA) PRIVATE KEY-----$")
OPENSSL_PROC_TYPE = "Proc-Type: "
OPENSSL_ENCRYPTED = "ENCRYPTED"
