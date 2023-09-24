import matplotlib.pyplot as plt
import numpy as np
import scipy

para = {
    'kappa' : 1,
    'gamma' : 0.5,
    'beta' : 0.3,
    'ubf' : 0.3
}
para.update({
    'base_bp' : (1 / para['gamma']) * ((1 / para['gamma'] - 1) ** (para['gamma'] - 1)) * (para['kappa'] ** (1 - para['gamma'])),
    'z' : (1-para['beta']) ** (1-para['beta']) * para['beta'] ** para['beta'],
    'K' : (para['kappa']/(1/para['gamma']-1))**(para['gamma'])
})
output = {}

def ph_o(h):
    return para['base_bp'] * (para['ubf'] +  h / para['z'])

def nvpb_s(b):
    if b < (para['kappa']/((1/para['gamma'])-1)) ** para['gamma']:
        return b ** ((1 / para['gamma']) - 1) + para['kappa']/b
    else:
        return para['base_bp']

pb_s = np.vectorize(nvpb_s)

def ph_s(h):
    b = h / para['z'] + para['ubf']
    return pb_s(b) * (para['ubf'] +  h / para['z'])

def d_o(b):
    return (para['kappa']/((1/para['gamma'])-1))**para['gamma']/b

def b_far(h,d,bf):
    return (h/(bf/d - para['ubf'])**(1-para['beta']))**(1/para['beta'])+bf/d

def nvph_farmin(h,d,bf):
    return ((d * b_far(h,d,bf))**(1/para['gamma']) + para['kappa'])/d

def temp(bf):
    A = bf * (para['kappa']/(1/para['gamma']-1))**(-para['gamma'])
    return para['z'] * para['ubf'] * ((1-A)/(A-1+para['beta']))

def temp2(bf):
    A = bf * (para['kappa']/(1/para['gamma']-1))**(-para['gamma'])
    return para['z'] * para['ubf'] * ((1-A)/(A))

def nvph_far(h,bf):
    A = bf * (para['kappa']/(1/para['gamma']-1))**(-para['gamma'])

    if h >= para['z'] * para['ubf'] * ((1-A)/(A-1+para['beta'])) and (A-1+para['beta']) > 0:
        return para['base_bp'] * (para['ubf'] +  h / para['z'])
    
    d0 = d_o(h/para['z'] + para['ubf'])
    # bounds = [(bf/para['ubf'] + 0.1, None)]
    d0l = bf / (h/para['z'] * (1- para['beta']) + para['ubf'])
    bounds = [(d0l, min(d0,bf/para['ubf']))]
    result = scipy.optimize.minimize(nvph_farmin, d0l, args=(h, bf), bounds=bounds, method = 'trust-constr')
    print('---')
    print(d0)
    print(d0l)
    print(result.x)
    print(nvph_farmin(h,result.x,bf))
    return nvph_farmin(h,result.x,bf)

def unrestrain_bh(h):
    return ((1-para['beta'])+para['beta']*para['ubf']*(h/para['z']+para['ubf'])**(-1))*para['K']

pb_far = np.vectorize(nvph_far)

x = np.linspace(0.001, 10, 100)
ys = ph_s(x)
yo = ph_o(x)
bh = unrestrain_bh(x)
yfar = pb_far(x,0.4)
plt.plot(x, ys)
plt.plot(x, yo)
plt.plot(x, bh)
plt.plot(x, yfar)
plt.show()


# x = np.linspace(0.01, 2, 10000)
# ys = temp(x)
# yo = temp2(x)
# plt.plot(x, ys)
# plt.plot(x, yo)
# plt.show()
