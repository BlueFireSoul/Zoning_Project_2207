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
import scipy

para = {
    'kappa' : 2,
    'gamma' : 0.4,
    'beta' : 0.7,
    'ubf' : 0.3
}
para.update({
    'base_bp' : (1 / para['gamma']) * ((1 / para['gamma'] - 1) ** (para['gamma'] - 1)) * (para['kappa'] ** (1 - para['gamma'])),
    'zb' : (1-para['beta']) ** (1-para['beta']) * para['beta'] ** para['beta'],
    'K' : (para['kappa']/(1/para['gamma']-1))**(para['gamma'])
})
output = {}

def ph_o(h):
    return para['base_bp'] * (para['ubf'] +  h / para['zb'])

def nvpb_s(b):
    if b < (para['kappa']/((1/para['gamma'])-1)) ** para['gamma']:
        return b ** ((1 / para['gamma']) - 1) + para['kappa']/b
    else:
        return para['base_bp']

pb_s = np.vectorize(nvpb_s, otypes=[float])

def ph_s(h):
    b = h / para['zb'] + para['ubf']
    return pb_s(b) * (para['ubf'] +  h / para['zb'])

def d_o(b):
    return (para['kappa']/((1/para['gamma'])-1))**para['gamma']/b

def b_o(h):
    return h/para['zb'] + para['ubf']

def d_far(h,bf):
    return bf/(h * (1- para['beta'])/para['zb'] + para['ubf'])

def nvph_far(h,bf):
    A = bf * (para['kappa']/(1/para['gamma']-1))**(-para['gamma'])

    if h >= para['zb'] * para['ubf'] * ((1-A)/(A-1+para['beta'])) and (A-1+para['beta']) > 0:
        return para['base_bp'] * (para['ubf'] +  h / para['zb'])
    else:
        return ((d_far(h,bf)*b_o(h)) ** (1/para['gamma']) + para['kappa'])/d_far(h,bf)

def bh_o(h):
    return ((1-para['beta'])+para['beta']*para['ubf']*(h/para['zb']+para['ubf'])**(-1))*para['K']

def hh_do(b):
    return (b-para['ubf'])*(1-para['beta'])+para['ubf']

def nvbh_s(h):
    b = b_o(h)
    if b < (para['kappa']/((1/para['gamma'])-1)) ** para['gamma']:
        return hh_do(b)
    else:
        return bh_o(h)
    
def nvbh_far(h,bf):
    A = bf * (para['kappa']/(1/para['gamma']-1))**(-para['gamma'])
    if h >= para['zb'] * para['ubf'] * ((1-A)/(A-1+para['beta'])) and (A-1+para['beta']) > 0:
        return bh_o(h)
    else:
        return bf

def d_ho(h):
    b = b_o(h)
    return d_o(b)

def nvd_s(h):
    b = b_o(h)
    if b < (para['kappa']/((1/para['gamma'])-1)) ** para['gamma']:
        return 1
    return d_o(b)

def nvd_far(h,bf):
    A = bf * (para['kappa']/(1/para['gamma']-1))**(-para['gamma'])
    if h >= para['zb'] * para['ubf'] * ((1-A)/(A-1+para['beta'])) and (A-1+para['beta']) > 0:
        return d_ho(h)
    else:
        b = b_o(h)
        return bf/hh_do(b)

def pb_far(x,ut):
    vec = np.vectorize(nvph_far, otypes=[float])
    return vec(x,ut)

def bh_far(x,ut):
    vec = np.vectorize(nvbh_far, otypes=[float])
    return vec(x,ut)

def d_far(x,ut):
    vec = np.vectorize(nvd_far, otypes=[float])
    return vec(x,ut)

def bh_s(x):
    vec = np.vectorize(nvbh_s, otypes=[float])
    return vec(x)
def d_s(x):
    vec = np.vectorize(nvd_s, otypes=[float])
    return vec(x)

def hhf_o(h):
    return bh_o(h) / d_ho(h)

def hhf_s(h):
    return bh_s(h) / d_s(h)

def hhf_far(h,bf):
    return bh_far(h,bf)/d_far(h,bf)

def floorspace(x):
    return x/para['base_bp'] * (1-para['beta']) + para['ubf']

x = np.linspace(0.001, 1, 1000)

ys = ph_s(x)
yo = ph_o(x)
yfar4 = pb_far(x,0.4)
plt.plot(x, yo, label='Original', color='blue')
plt.plot(x, yfar4, label='FAR Limit', color='red', linestyle='dashed')
plt.plot(x, ys, label='Density Limit', color='green', linestyle='dotted')
plt.xlabel('Housing Quality $(h)$')
plt.ylabel('Housing Cost $(h^{H})$')
plt.legend(fontsize='large')
plt.savefig(os.path.join(graph_output_dir, "cost_simulation_hcost_highk.png"))
plt.clf()

bh = bh_o(x)
bh_se = bh_s(x)
bh_far4 = bh_far(x,0.4)
plt.plot(x, bh, label='Original', color='blue')
plt.plot(x, bh_far4, label='FAR Limit', color='red', linestyle='dashed')
plt.plot(x, bh_se, label='Density Limit', color='green', linestyle='dotted')
plt.xlabel('Housing Quality $(h)$')
plt.ylabel('FAR $(df)$')
plt.legend(fontsize='large')
plt.savefig(os.path.join(graph_output_dir, "cost_simulation_btotalspace_highk.png"))
plt.clf()

bh = d_ho(x)
bh_se = d_s(x)
bh_far4 = d_far(x,0.4)
plt.plot(x, bh, label='Original', color='blue')
plt.plot(x, bh_far4, label='FAR Limit', color='red', linestyle='dashed')
plt.plot(x, bh_se, label='Density Limit', color='green', linestyle='dotted')
plt.xlabel('Housing Quality $(h)$')
plt.ylabel('Building Density $(d)$')
plt.legend(fontsize='large')
plt.savefig(os.path.join(graph_output_dir, "cost_simulation_bdensity_highk.png"))
plt.clf()

ys = ph_s(x)
yo = ph_o(x)
yfar4 = pb_far(x,0.4)
plt.plot(floorspace(x), yo, label='Original', color='blue')
plt.plot(floorspace(x), yfar4, label='FAR Limit', color='red', linestyle='dashed')
plt.plot(floorspace(x), ys, label='Density Limit', color='green', linestyle='dotted')
plt.xlabel('Housing Unit Size $(f)$')
plt.ylabel('Housing Cost $(h^{H})$')
plt.legend(fontsize='large')
plt.savefig(os.path.join(graph_output_dir, "cost_simulation_hcost_pu.png"))
plt.clf()

bh = bh_o(x)
bh_se = bh_s(x)
bh_far4 = bh_far(x,0.4)
plt.plot(floorspace(x), bh, label='Original', color='blue')
plt.plot(floorspace(x), bh_far4, label='FAR Limit', color='red', linestyle='dashed')
plt.plot(floorspace(x), bh_se, label='Density Limit', color='green', linestyle='dotted')
plt.xlabel('Housing Unit Size $(f)$')
plt.ylabel('FAR $(df)$')
plt.legend(fontsize='large')
plt.savefig(os.path.join(graph_output_dir, "cost_simulation_btotalspace_hcost_pu.png"))
plt.clf()

bh = 1/d_ho(x)
bh_s = 1/d_s(x)
bh_far4 = 1/d_far(x,0.4)
plt.plot(floorspace(x), bh, label='Original', color='blue')
plt.plot(floorspace(x), bh_far4, label='FAR Limit', color='red', linestyle='dashed')
plt.plot(floorspace(x), bh_s, label='Density Limit', color='green', linestyle='dotted')
plt.xlabel('Housing Unit Size $(f)$')
plt.ylabel('Land Per Housing Unit $(k)$')
plt.legend(fontsize='large')
plt.savefig(os.path.join(graph_output_dir, "cost_simulation_bdensity_hcost_pu.png"))
plt.clf()

ys = ph_s(x)
plt.plot(floorspace(x), yo, label='', color='blue')
plt.xlabel('Housing Unit Size $(f)$')
plt.ylabel('Housing Cost $(h^{H})$')
plt.legend(fontsize='large')
plt.savefig(os.path.join(graph_output_dir, "cost_simulation_hcost_puo.png"))
plt.clf()

bh = bh_o(x)
plt.plot(floorspace(x), bh, label='', color='blue')
plt.xlabel('Housing Unit Size $(f)$')
plt.ylabel('FAR $(df)$')
plt.legend(fontsize='large')
plt.savefig(os.path.join(graph_output_dir, "cost_simulation_btotalspace_hcost_puo.png"))
plt.clf()

bh = 1/d_ho(x)
plt.plot(floorspace(x), bh, label='', color='blue')
plt.xlabel('Housing Unit Size $(f)$')
plt.ylabel('Land Per Housing Unit $(k)$')
plt.legend(fontsize='large')
plt.savefig(os.path.join(graph_output_dir, "cost_simulation_bdensity_hcost_puo.png"))
plt.clf()