#! /usr/bin/python3

def hexstring_to_int(s):
    x = int(s, 16)
    if x & (1 << 15):
        x -= (1 << 16)
    return x

def int_to_hexstring(x):
    x &= 0xFFFF
    return "%0.4x" % x

with open("cos_lut_sirius_50_191.dat", "r") as cos_file:
    with open("sin_lut_sirius_50_191.dat", "r") as sin_file:
        # SFIX32_31
        cos = [(hexstring_to_int(sample.strip()) / (2 ** 15)) for sample in cos_file.readlines()]
        sin = [(hexstring_to_int(sample.strip()) / (2 ** 15)) for sample in sin_file.readlines()]

with open("bpm_readings.dat", "r") as bpm_readings_file:
    bpm_readings = [int(sample.strip()) for sample in bpm_readings_file.readlines()]

    i, q = [], []
    for sample_idx in range(len(bpm_readings)):
        i.append(int(round(cos[sample_idx % 191] * bpm_readings[sample_idx])))
        q.append(int(round(sin[sample_idx % 191] * bpm_readings[sample_idx])))

with open("i.dat", "w") as i_file:
    with open("q.dat", "w") as q_file:
        i_file.write("\n".join(int_to_hexstring(sample) for sample in i))
        q_file.write("\n".join(int_to_hexstring(sample) for sample in q))
