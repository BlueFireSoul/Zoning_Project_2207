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
import scipy.optimize as opt
import scipy

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


    
def prob_far(w,kappa,bf):
    if far_nr_dummy(w,kappa,bf):
        return prob_nr(w,kappa)
    
    A = ((w - fixed_cost_far(bf,kappa))/pb_far(bf,kappa)**(1-para['alpha']))** para['theta']
    B = ((w - base_bp(1) * para['ubf'])/base_bp(1)**(1-para['alpha']))** para['theta'] 
    if w - fixed_cost_far(bf,kappa) <= 0:
        return 0
    return A/(A+B)

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


def bfar(h,d,bf):
    A = bf/d
    return (h/(A-para['ubf'])**(1-para['beta']))**(1/para['beta'])+A

def bfar_cost(d,h,bf,kappa):
    return ((d * bfar(h,d,bf)) ** (1/para['gamma'])+ kappa)/d

def h_far(w,kappa,bf):
    if far_nr_dummy(w,kappa,bf):
        return h_nr(w,kappa)
    else:
        return (1-para['beta']) * (w - fixed_cost_far(bf,kappa)) * para['zb']/pb_far(bf,kappa)

def d_far(w,kappa,bf):
    if far_nr_dummy(w,kappa,bf):
        return d_nr(w,kappa)
    else:
        d0 = bf/((1-para['beta'])* h_far(w,kappa,bf)/para['zb']+para['ubf'])
        # return d0
        result = opt.minimize(bfar_cost, d0, args=(h_far(w,kappa,bf), bf, kappa))
        print('----------')
        print(kappa)
        print(d0)
        print(d0-result.x[0])
        # print(result)
        return result.x[0]

def vd_far(x):
    output = []
    for i in x:
        output += [d_far(1,i,bf)]
    return output

def vd_nr(x):
    output = []
    for i in x:
        output += [d_nr(1,i)]
    return output


def h_far(w,kappa,bf):
    if far_nr_dummy(w,kappa,bf):
        return h_nr(w,kappa)
    else:
        return (1-para['beta']) * (w - fixed_cost_far(bf,kappa)) * para['zb']/pb_far(bf,kappa)
    

def f_nr_test(h,kappa):
    return (1-para['beta'])*b(h) + para['beta'] * d_nr_test(h,kappa) * para['ubf']
bf = 1
def h_far_test(w,kappa,bf):
    return (1-para['beta']) * (w - fixed_cost_far(bf,kappa)) * para['zb']/pb_far(bf,kappa)
    
def vh_far(x):
    output = []
    for i in x:
        output += [h_far(1,i,bf)]
    return output
def vh_test_far(x):
    output = []
    for i in x:
        output += [h_far_test(1,i,bf)]
    return output

x = np.linspace(0.5, 2, 100)
yz = vd_far(x)
plt.scatter(x, yz)
yz = vd_nr(x)
plt.plot(x, yz)
plt.show()
plt.clf()
