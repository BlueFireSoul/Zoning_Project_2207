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
    'kappa' : 1,
    'gamma' : 0.5,
    'beta' : 0.3,
    'ubf' : 0.3,
    'alpha' : 0.7
}
para.update({
    'base_bp' : (1 / para['gamma']) * ((1 / para['gamma'] - 1) ** (para['gamma'] - 1)) * (para['kappa'] ** (1 - para['gamma'])),
    'zb' : (1-para['beta']) ** (1-para['beta']) * para['beta'] ** para['beta'],
    'za' : (1-para['alpha']) ** (1-para['alpha']) * para['alpha'] ** para['alpha'],
    'K' : (para['kappa']/(1/para['gamma']-1))**(para['gamma'])
})
output = {}

def nvU(w,h,p):
    if w < p:
        return 0
    return (w-p) ** para['alpha'] * h ** (1- para['alpha'])

def ph_o(h):
    return para['base_bp'] * (para['ubf'] +  h / para['zb'])

def nvpb_s(b):
    if b < (para['kappa']/((1/para['gamma'])-1)) ** para['gamma']:
        return b ** ((1 / para['gamma']) - 1) + para['kappa']/b
    else:
        return para['base_bp']

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
    
U = np.vectorize(nvU)
pb_s = np.vectorize(nvpb_s)

pb_far = np.vectorize(nvph_far)
def ph_s(h):
    b = h / para['zb'] + para['ubf']
    return pb_s(b) * (para['ubf'] +  h / para['zb'])

w = 3
x = np.linspace(0.001, 0.5, 100)
ys = U(w,x,ph_s(x)) 
yo = U(w,x,ph_o(x)) 
y_far = U(w,x,pb_far(x,0.7))
y_far4 = U(w,x,pb_far(x,0.5))
plt.plot(x, yo, label='Original', color='blue')
plt.plot(x, ys, label='SFZ', color='green')
plt.plot(x, y_far, label='FAR', color='Red', linestyle='--')
plt.plot(x, y_far4, label='FAR4', color='Red', linestyle='dotted')

# Mark maximum points for the Original curve
max_yo_index = np.argmax(yo)
max_yo_x = x[max_yo_index]
max_yo_y = yo[max_yo_index]
plt.scatter(max_yo_x, max_yo_y, color='red')
plt.annotate(f'({max_yo_x:.3f}, {max_yo_y:.3f})', (max_yo_x, max_yo_y), xytext=(10, -20),
             textcoords='offset points', arrowprops=dict(arrowstyle="->", color='red'))

# Mark maximum points for the SFZ curve
max_ys_index = np.argmax(ys)
max_ys_x = x[max_ys_index]
max_ys_y = ys[max_ys_index]
plt.scatter(max_ys_x, max_ys_y, color='red')
plt.annotate(f'({max_ys_x:.3f}, {max_ys_y:.3f})', (max_ys_x, max_ys_y), xytext=(-50, 20),
             textcoords='offset points', arrowprops=dict(arrowstyle="->", color='red'))

# Mark maximum points for the SFZ curve
max_ys_index = np.argmax(y_far4)
max_ys_x = x[max_ys_index]
max_ys_y = y_far4[max_ys_index]
plt.scatter(max_ys_x, max_ys_y, color='red')
plt.annotate(f'({max_ys_x:.3f}, {max_ys_y:.3f})', (max_ys_x, max_ys_y), xytext=(-50, 20),
             textcoords='offset points', arrowprops=dict(arrowstyle="->", color='red'))

plt.legend()
plt.savefig(os.path.join(script_dir, "graph/graph.png"))
plt.clf()