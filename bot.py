#!/usr/bin/env python3
"""
resbot - Bot de Telegram para gestion de usuarios VPN/SSH
MI VPS1 AWS
"""
import subprocess
import time
import json
import urllib.request
import urllib.parse
import re
import datetime
import os

BOT_TOKEN = "REEMPLAZAR_TOKEN"
ADMIN_ID = 261559621
API_URL = f"https://api.telegram.org/bot{BOT_TOKEN}"

BASE_DIR = "/etc/resbot"
LIMITS_DIR = f"{BASE_DIR}/limits"
TRIALS_DIR = f"{BASE_DIR}/trials"
os.makedirs(LIMITS_DIR, exist_ok=True)
os.makedirs(TRIALS_DIR, exist_ok=True)


def api_call(method, params=None):
    url = f"{API_URL}/{method}"
    data = None
    if params:
        data = urllib.parse.urlencode(params).encode()
    try:
        with urllib.request.urlopen(url, data=data, timeout=35) as resp:
            return json.loads(resp.read())
    except Exception as e:
        print(f"API error: {e}")
        return {}


def send_message(chat_id, text):
    api_call("sendMessage", {"chat_id": chat_id, "text": text})


def run(cmd):
    result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    return result.stdout.strip(), result.stderr.strip(), result.returncode


# ---------- Comandos ----------

def cmd_adduser(args):
    if len(args) < 1:
        return "Uso: /adduser nombre"
    user = args[0]
    password = user
    exp_date = (datetime.date.today() + datetime.timedelta(days=30)).strftime("%Y-%m-%d")
    out, err, rc = run(f"useradd -e {exp_date} -M -s /bin/false {user}")
    if rc != 0:
        return f"Error creando usuario:\n{err}"
    run(f"echo '{user}:{password}' | chpasswd")
    return f"Usuario creado\nNombre: {user}\nPassword: {password}\nExpira: {exp_date} (30 dias)"


def cmd_trial(args):
    if len(args) < 2:
        return "Uso: /trial nombre horas"
    user, horas = args[0], args[1]
    if not horas.isdigit():
        return "Las horas deben ser un numero"
    password = user
    out, err, rc = run(f"useradd -M -s /bin/false {user}")
    if rc != 0:
        return f"Error creando usuario:\n{err}"
    run(f"echo '{user}:{password}' | chpasswd")
    expiry_epoch = time.time() + int(horas) * 3600
    with open(f"{TRIALS_DIR}/{user}", "w") as f:
        f.write(str(expiry_epoch))
    return f"Usuario trial creado\nNombre: {user}\nPassword: {password}\nExpira en: {horas} horas"


def cmd_deluser(args):
    if len(args) < 1:
        return "Uso: /deluser nombre"
    user = args[0]
    out, err, rc = run(f"userdel -r {user}")
    for d in (LIMITS_DIR, TRIALS_DIR):
        p = f"{d}/{user}"
        if os.path.exists(p):
            os.remove(p)
    if rc != 0:
        return f"Error eliminando usuario:\n{err}"
    return f"Usuario eliminado: {user}"


def get_all_vps_users():
    out, _, _ = run(
        "awk -F: '$3>=1000 && $1!=\"ubuntu\" && $1!=\"nobody\" {print $1}' /etc/passwd"
    )
    return [u for u in out.splitlines() if u]


def days_left(user):
    out, _, _ = run(f"chage -l {user}")
    m = re.search(r"Account expires\s*:\s*(.+)", out)
    if not m:
        return "Sin expiracion"
    val = m.group(1).strip()
    if val.lower() == "never":
        return "Sin expiracion"
    try:
        exp_date = datetime.datetime.strptime(val, "%b %d, %Y").date()
        delta = (exp_date - datetime.date.today()).days
        if delta < 0:
            return "Expirado"
        return f"{delta} dias"
    except Exception:
        return val


def cmd_listuser(args):
    users = get_all_vps_users()
    if not users:
        return "No hay usuarios creados"
    lines = ["Usuarios:"]
    for u in users:
        lines.append(f"{u} - {days_left(u)}")
    return "\n".join(lines)


def cmd_checkuser(args):
    if len(args) < 1:
        return "Uso: /checkuser nombre"
    user = args[0]
    out, err, rc = run(f"id {user}")
    if rc != 0:
        return f"El usuario {user} no existe"
    limit_file = f"{LIMITS_DIR}/{user}"
    limit = "Sin limite"
    if os.path.exists(limit_file):
        with open(limit_file) as f:
            limit = f.read().strip() + " conexiones"
    return f"Usuario: {user}\nExpira: {days_left(user)}\nLimite IP: {limit}"


def cmd_time(args):
    if len(args) < 2:
        return "Uso: /time nombre dias"
    user, dias = args[0], args[1]
    if not dias.isdigit():
        return "Los dias deben ser un numero"
    exp_date = (datetime.date.today() + datetime.timedelta(days=int(dias))).strftime("%Y-%m-%d")
    out, err, rc = run(f"chage -E {exp_date} {user}")
    if rc != 0:
        return f"Error:\n{err}"
    return f"Fecha actualizada\nUsuario: {user}\nNueva expiracion: {exp_date} ({dias} dias)"


def cmd_limit(args):
    if len(args) < 2:
        return "Uso: /limit nombre numero"
    user, numero = args[0], args[1]
    if not numero.isdigit():
        return "El limite debe ser un numero"
    with open(f"{LIMITS_DIR}/{user}", "w") as f:
        f.write(numero)
    return f"Limite actualizado\nUsuario: {user}\nMaximo de conexiones: {numero}"


def cmd_status(args):
    ip, _, _ = run("curl -s ifconfig.me")
    uptime, _, _ = run("uptime -p")
    ram, _, _ = run("free -m | awk 'NR==2{print $3\"/\"$2\" MB\"}'")
    disk, _, _ = run("df -h / | awk 'NR==2{print $3\"/\"$2}'")
    return f"Estado\nIP: {ip}\nUptime: {uptime}\nRAM: {ram}\nDisco: {disk}"


def cmd_online(args):
    users = get_all_vps_users()
    lines = ["Usuarios conectados:"]
    any_online = False
    for u in users:
        out, _, _ = run(f"pgrep -c -u {u}")
        count = int(out) if out.isdigit() else 0
        if count > 0:
            lines.append(f"{u}: {count} sesion(es)")
            any_online = True
    if not any_online:
        return "No hay usuarios conectados"
    return "\n".join(lines)


def cmd_restart(args):
    services = ["edu", "xray", "dropbear", "nginx", "ssh"]
    for s in services:
        run(f"systemctl restart {s}")
    return "Servicios reiniciados: " + ", ".join(services)


COMMANDS = {
    "/adduser": cmd_adduser,
    "/trial": cmd_trial,
    "/deluser": cmd_deluser,
    "/listuser": cmd_listuser,
    "/checkuser": cmd_checkuser,
    "/time": cmd_time,
    "/limit": cmd_limit,
    "/status": cmd_status,
    "/online": cmd_online,
    "/restart": cmd_restart,
}

MENU_TEXT = """Panel VPS
---------------
/adduser nombre
/trial nombre horas
/deluser nombre
/listuser
/checkuser nombre
/time nombre dias
/limit nombre numero
/status
/online
/restart
---------------
Bot activo"""


def handle_message(msg):
    chat_id = msg["chat"]["id"]
    if chat_id != ADMIN_ID:
        return
    text = msg.get("text", "").strip()
    if not text.startswith("/"):
        return
    parts = text.split()
    cmd = parts[0].split("@")[0]
    args = parts[1:]

    if cmd in ("/start", "/menu"):
        send_message(chat_id, MENU_TEXT)
        return

    handler = COMMANDS.get(cmd)
    if not handler:
        send_message(chat_id, "Comando no reconocido. Usa /menu")
        return
    try:
        reply = handler(args)
    except Exception as e:
        reply = f"Error ejecutando comando: {e}"
    send_message(chat_id, reply)


def check_trials():
    now = time.time()
    if not os.path.isdir(TRIALS_DIR):
        return
    for fname in list(os.listdir(TRIALS_DIR)):
        path = f"{TRIALS_DIR}/{fname}"
        try:
            with open(path) as f:
                expiry = float(f.read().strip())
        except Exception:
            continue
        if now >= expiry:
            run(f"userdel -r {fname}")
            os.remove(path)
            send_message(ADMIN_ID, f"Trial expirado, usuario eliminado: {fname}")


def check_limits():
    if not os.path.isdir(LIMITS_DIR):
        return
    for fname in os.listdir(LIMITS_DIR):
        path = f"{LIMITS_DIR}/{fname}"
        try:
            with open(path) as f:
                limit = int(f.read().strip())
        except Exception:
            continue
        user = fname
        out, _, _ = run(f"pgrep -c -u {user}")
        count = int(out) if out.isdigit() else 0
        if count > limit:
            pids_out, _, _ = run(f"pgrep -u {user}")
            pids = pids_out.splitlines()
            for pid in pids[: count - limit]:
                run(f"kill -9 {pid}")


def main():
    print("resbot iniciado")
    offset = None
    while True:
        params = {"timeout": 25}
        if offset:
            params["offset"] = offset
        resp = api_call("getUpdates", params)
        for update in resp.get("result", []):
            offset = update["update_id"] + 1
            if "message" in update:
                handle_message(update["message"])
        check_trials()
        check_limits()
        time.sleep(1)


if __name__ == "__main__":
    main()
