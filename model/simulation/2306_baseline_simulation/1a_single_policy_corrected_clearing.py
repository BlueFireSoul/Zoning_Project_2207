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

para = {
    'gamma' : 0.5,
    'beta' : 0.8,
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

def prob_nr(w,kappa):
    A = ((w - base_bp(kappa) * para['ubf'])/base_bp(kappa)**(1-para['alpha']))** para['theta']
    B = ((w - base_bp(1) * para['ubf'])/base_bp(1)**(1-para['alpha']))** para['theta'] 
    if w - base_bp(kappa) * para['ubf'] <= 0:
        return 0
    return A/(A+B)

def h_nr(w,kappa):
    return (1-para['alpha'])*(w-para['ubf']*base_bp(kappa))*para['zb']/base_bp(kappa)

def b(h):
    return h/para['zb'] + para['ubf']

def g(kappa):
    return (kappa/(1/para['gamma']-1))**(para['gamma'])

def d_nr(w,kappa):
    return b(h_nr(w,kappa)) **(-1) * g(kappa)

def nvland_demand(w,kappa,L):
    if (w - base_bp(kappa) * para['ubf'])<=0:
        return 0
    return L * prob_nr(w,kappa) / d_nr(w,kappa)


w = np.linspace(1, 10, 100)
L = 2.5/100
kappa01 = 1
kappa02 = 1

def land_demand(w,kappa,share):
    temp = np.vectorize(nvland_demand, otypes=[float])
    return temp(w,kappa,share)

def demand_supply_diff(kappa):
    supply = sum(land_demand(w,kappa,L))
    return 1 - supply

# result = fsolve(demand_supply_diff, kappa01)
# print("Kappa: ", result[0])

def vland_demand(x):
    output = []
    for i in x:
        output += [sum(land_demand(w,i,L))]
    return output

# plt.legend()
# plt.show()
# plt.clf()

###########################################################################################################


def fixed_cost_far(bf,kappa):
    return (para['zp'] * bf ** (1/para['gamma']) + kappa) * para['ubf'] / bf

def pb_far(bf,kappa):
    return (1-para['beta']) * (kappa + para['zp'] * bf ** (1/para['gamma'])) / bf

def far_nr_dummy(w,kappa,bf):
    gk = g(kappa)
    A = bf * gk ** (-1)
    return bf > (1-para['beta']) * gk and h_nr(w,kappa) >= para['zb'] * para['ubf'] * ((1-A)/(A-1+para['beta']))

def h_far(w,kappa,bf):
    if far_nr_dummy(w,kappa,bf):
        return h_nr(w,kappa)
    else:
        return (1-para['beta']) * (w - fixed_cost_far(bf,kappa)) * para['zb']/pb_far(bf,kappa)
    
def prob_far(w,kappa,bf):
    if far_nr_dummy(w,kappa,bf):
        return prob_nr(w,kappa)
    
    A = ((w - fixed_cost_far(bf,kappa))/pb_far(bf,kappa)**(1-para['alpha']))** para['theta']
    B = ((w - base_bp(1) * para['ubf'])/base_bp(1)**(1-para['alpha']))** para['theta'] 
    if w - fixed_cost_far(bf,kappa) <= 0:
        return 0
    return A/(A+B)

def d_far(w,kappa,bf):
    if far_nr_dummy(w,kappa,bf):
        return d_nr(w,kappa)
    else:
        return bf/((1-para['beta'])* h_far(w,kappa,bf)/para['zb']+para['ubf'])
    
def nvland_demand_far(w,kappa,L,bf):
    return L * prob_far(w,kappa,bf) / d_far(w,kappa,bf)


def land_demand_far(w,kappa,share,bf):
    temp = np.vectorize(nvland_demand_far, otypes=[float])
    return temp(w,kappa,share,bf)


def demand_supply_dif_far(kappa):
    supply = sum(land_demand_far(w,kappa,L,bf))
    return 1 - supply

# result = fsolve(demand_supply_dif_far, kappa02)
# print("Kappa: ", result[0])
# print(sum(labor_market_far(w,result[0],L,bf)))


# w = np.linspace(1, 10, 1000)
# L = 2.5/1000


# x = np.linspace(0.1, 8, 1000)
# kappa01 = 1
# kappa02 = 1

def vland_demand_far(x):
    output = []
    for i in x:
        output += [sum(land_demand_far(w,i,L,bf))]
    return output


###############################################################################################################


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
    return h_opt_guess(w,kappa)
    result = fsolve(h_opt, h_opt_guess(w,kappa), args=(w,kappa))
    return result[0]

def hprice_sfz(w,kappa):
    if sfz_nr_dummy(w,kappa):
        return b(h_nr(w,kappa)) *base_bp(kappa)
    else:
        b1 = b(h_sfz(w,kappa))
        return b1 ** (1/para['gamma']) + kappa

def prob_sfz(w,kappa):
    if sfz_nr_dummy(w,kappa):
        return prob_nr(w,kappa)
    h1 = hprice_sfz(w,kappa)
    A = (w - h1) ** para['alpha'] * (h_sfz(w,kappa)) ** (1-para['alpha'])
    B = (para['za']*(w - base_bp(1) * para['ubf'])/(base_bp(1)/para['zb'])**(1-para['alpha']))** para['theta'] 
    if w - h1 <= 0:
        return 0
    return A/(A+B)

def d_sfz(w,kappa):
    if sfz_nr_dummy(w,kappa):
        return d_nr(w,kappa)
    else:
        return 1
    
def nvland_demand_sfz(w,kappa,L):
    if (w - kappa)<=0:
        return 0
    return L * prob_sfz(w,kappa) / d_sfz(w,kappa)


w = np.linspace(1, 10, 100)
L = 2.5/100
bf = 0.8
kappa01 = 1
kappa02 = 1
kappa03 = 1

def land_demand_sfz(w,kappa,share):
    temp = np.vectorize(nvland_demand_sfz, otypes=[float])
    return temp(w,kappa,share)

def demand_supply_diff_sfz(kappa):
    supply = sum(land_demand_sfz(w,kappa,L))
    return 1 - supply


# result = fsolve(demand_supply_diff_sfz, kappa03)
# print("Kappa: ", result[0])
# print(sum(labor_market_sfz(w,result[0],L)))
# print(demand_supply_diff_sfz(result[0]))

# kappa03 = 1.0667656418969422
# print(sum(labor_market_sfz(w,kappa03,L)))
# print(demand_supply_diff_sfz(kappa03))
###########

def vland_demand_sfz(x):
    output = []
    for i in x:
        output += [sum(land_demand_sfz(w,i,L))]
    return output


bf = 1
x = np.linspace(0.5, 5, 1000)

yz = vland_demand(x)
plt.plot(x, yz, label='NR Land Demand', color='red', linestyle='dotted')
yz = vland_demand_far(x)
plt.scatter(x, yz, label='FAR Land Demand')
yz = vland_demand_sfz(x)
plt.scatter(x, yz, label='SFZ Land Demand')
plt.legend()
plt.show()
plt.clf()
