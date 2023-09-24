import os
import getpass
import sys
script_dir = os.path.dirname(os.path.abspath(__file__))
os.chdir(script_dir)
current_user = getpass.getuser()
sys.path.append(f"C:/Users/{current_user}/OneDrive - The Pennsylvania State University/2207 - Zoning - exercise")
from config import *
import matplotlib.pyplot as plt
import numpy as np
from scipy.optimize import fsolve
import scipy
import math

from argparse import ArgumentParser

P = ArgumentParser()
P.add_argument("-noguess", help="", action = 'store_true')
args = P.parse_args()

para = {
    'gamma' : 0.5,
    'beta' : 0.3,
    'ubf' : 0.3,
    'alpha' : 0.7,
    'theta' : 3,
    'D' : 1,
    'zp' : 1
}

para.update({
    'zb' : (1-para['beta']) ** (1-para['beta']) * para['beta'] ** para['beta'],
    'za' : (1-para['alpha']) ** (1-para['alpha']) * para['alpha'] ** para['alpha']
})
output = {}

def base_bp(kappa):
    return (1 / para['gamma']) * ((1 / para['gamma'] - 1) ** (para['gamma'] - 1)) * (kappa ** (1 - para['gamma']))

def h_nr(w,kappa):
    return (1-para['alpha'])*(w-para['ubf']*base_bp(kappa))*para['zb']/base_bp(kappa)

def U(w,phouse,h):
    if w - phouse <= 0:
        return 0
    return (w - phouse) ** para['alpha'] * (h) ** (1-para['alpha'])

def b(h):
    return h/para['zb'] + para['ubf']

def g(kappa):
    return (kappa/(1/para['gamma']-1))**(para['gamma'])

def d_nr(w,kappa):
    return b(h_nr(w,kappa)) **(-1) * g(kappa)

def sfz_nr_dummy(w,kappa):
    return b(h_nr(w,kappa)) >= g(kappa)

def h_opt(h,w,kappa):
    A = (para['ubf']+h/para['zb'])**(1/para['gamma'])
    B = para['alpha'] * para['ubf'] * para['gamma'] * para['zb'] + para['alpha'] * para['gamma'] * h - para['alpha'] * h - para['ubf'] * para['gamma'] * para['zb'] - para['gamma'] * h
    C = (para['alpha']-1)*para['gamma']*(para['ubf']*para['zb']+h)
    return -w + kappa + A * B / C

def h_opt_guess(w,kappa):
    A = w - kappa - para['ubf'] ** 1/para['gamma']
    B = (para['alpha'] - 1) * para['gamma']
    C = para['alpha'] * para['gamma'] - para['alpha'] - para['gamma']
    return (A * B /C) ** para['gamma'] * para['zp']

def h_sfz(w,kappa):
    if w <= kappa + para['ubf'] ** 1/para['gamma']:
        return 0
    if sfz_nr_dummy(w,kappa):
        return h_nr(w,kappa)
    if not args.noguess:
        return h_opt_guess(w,kappa)
    result = fsolve(h_opt, h_opt_guess(w,kappa), args=(w,kappa))
    return result[0]

def hprice_sfz(w,kappa):
    if sfz_nr_dummy(w,kappa):
        return b(h_nr(w,kappa)) *base_bp(kappa)
    else:
        b1 = b(h_sfz(w,kappa))
        return b1 ** (1/para['gamma']) + kappa

def d_sfz(w,kappa):
    if sfz_nr_dummy(w,kappa):
        return d_nr(w,kappa)
    else:
        return 1

def nvnr_region_dummy(w,kappa1,kappa2):
    nr_region_U = U(w,b(h_nr(w,kappa1)) * base_bp(kappa1),h_nr(w,kappa1))
    sfz_region_U = U(w,hprice_sfz(w,kappa2),h_sfz(w,kappa2))
    if nr_region_U <= sfz_region_U:
        return 0
    return 1

def nr_region_dummy(w,kappa1,kappa2):
    temp = np.vectorize(nvnr_region_dummy, otypes=[int])
    return temp(w,kappa1,kappa2)

def prob_nr(w,kappa):
    A = ((w - base_bp(kappa) * para['ubf'])/base_bp(kappa)**(1-para['alpha']))** para['theta']
    B = ((w - base_bp(1) * para['ubf'])/base_bp(1)**(1-para['alpha']))** para['theta'] 
    if w - base_bp(kappa) * para['ubf'] <= 0:
        return 0
    return A/(A+B)

def prob_sfz(w,kappa):
    if sfz_nr_dummy(w,kappa):
        return prob_nr(w,kappa)
    h1 = hprice_sfz(w,kappa)
    A = (w - h1) ** para['alpha'] * (h_sfz(w,kappa)) ** (1-para['alpha'])
    B = (para['za']*(w - base_bp(1) * para['ubf'])/(base_bp(1)/para['zb'])**(1-para['alpha']))** para['theta'] 
    if w - h1 <= 0:
        return 0
    return A/(A+B)

#### The density should clear for each land. 

def nvland_demand1(w,kappa1,share,dummy):
    if dummy == 0:
        return 0
    if (w - base_bp(kappa1) * para['ubf'])<=0:
        return 0
    return share *dummy * d_nr(w,kappa1)

def nvland_demand2(w,kappa2,share,dummy):
    if dummy == 0:
        return 0
    if (w - kappa2)<=0:
        return 0
    return share *dummy * d_sfz(w,kappa2)

def nvlabor_market2(w,kappa2,L, dummy):
    if dummy == 0:
        return 0
    return L *dummy  *prob_sfz(w,kappa2)

def nvlabor_market1(w,kappa1,L, dummy):
    if dummy == 0:
        return 0
    return L *dummy  * prob_nr(w,kappa1)

def land_demand1(w,kappa,share,dummy):
    temp = np.vectorize(nvland_demand1, otypes=[float])
    return temp(w,kappa,share,dummy)

def land_demand2(w,kappa,share,dummy):
    temp = np.vectorize(nvland_demand2, otypes=[float])
    return temp(w,kappa,share,dummy)

def labor_market1(w,kappa,L,dummy):
    temp = np.vectorize(nvlabor_market1, otypes=[float])
    return temp(w,kappa,L,dummy)

def labor_market2(w,kappa,L,dummy):
    temp = np.vectorize(nvlabor_market2, otypes=[float])
    return temp(w,kappa,L,dummy)

def demand_supply_diff(kappalist):
    kappa1 = math.exp(kappalist[0]) * (math.exp(kappalist[1]) + 1)
    kappa2 = math.exp(kappalist[0]) 
    nr_dummy = nr_region_dummy(w,kappa1,kappa2)
    sfz_dummy = 1- nr_dummy
    labor1 = land_demand1(w,kappa1,L,nr_dummy)
    labor2 = land_demand2(w,kappa2,L,sfz_dummy)
    # print(labor1)
    # print(labor2)
    demand1 = sum(labor1)
    demand2 = sum(labor2)
    share1 = labor1/demand1
    share2 = labor2/demand2
    supply1 = sum(land_demand1(w,kappa1,share1,nr_dummy))/2
    supply2 = sum(land_demand2(w,kappa2,share2,sfz_dummy))/2
    # print(supply1)
    # print(supply2)
    return np.array([demand1 - supply1,demand2 - supply2])

def nvlabor_market(w,kappa,L):
    return L * prob_nr(w,kappa)

w = np.linspace(1, 10, 10)
L = 2.5/10
kappa01 = 1
kappa02 = np.array([math.log(1),math.log(0.9)])
# print(demand_supply_diff(kappa02))
result = fsolve(demand_supply_diff, kappa02)
# print("Kappa: ", result[0])
# print(demand_supply_diff(result[0]))