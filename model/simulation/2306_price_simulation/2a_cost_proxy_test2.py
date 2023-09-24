import matplotlib.pyplot as plt
import numpy as np
import scipy

beta = 0.1
ubf = 0.7*0.3/beta

para = {
    'kappa' : 1,
    'gamma' : 0.5,
    'beta' : beta,
    'ubf' : ubf
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
    result = scipy.optimize.minimize(nvph_farmin, d0, args=(h, bf), bounds=bounds, method = 'trust-constr')
    print('---')
    print(d0)
    print(d0l)
    print(result.x)
    print(nvph_farmin(h,result.x,bf))
    return nvph_farmin(h,result.x,bf)

def unrestrain_bh(h):
    return ((1-para['beta'])+para['beta']*para['ubf']*(h/para['z']+para['ubf'])**(-1))*para['K']

pb_far = np.vectorize(nvph_far)

# x = np.linspace(0.001, 10, 100)
# ys = ph_s(x)
# yo = ph_o(x)
# bh = unrestrain_bh(x)
# plt.plot(x, ys)
# plt.plot(x, yo)
# plt.plot(x, bh)
# plt.show()

para = {
    'kappa' : 5,
    'gamma' : 0.5,
    'beta' : beta,
    'ubf' : ubf
}
para.update({
    'base_bp' : (1 / para['gamma']) * ((1 / para['gamma'] - 1) ** (para['gamma'] - 1)) * (para['kappa'] ** (1 - para['gamma'])),
    'z' : (1-para['beta']) ** (1-para['beta']) * para['beta'] ** para['beta'],
    'K' : (para['kappa']/(1/para['gamma']-1))**(para['gamma'])
})


h = 1
bf = 0.8
d0 = d_o(h/para['z'] + para['ubf'])
d0l = bf / (h/para['z'] * (1- para['beta']) + para['ubf'])
afar = bf/para['ubf']
x = np.linspace(max(d0l - 0.2, 0.0001), min(d0,afar-0.200000000000001) + 0.2, 100)
if d0 < d0l:
    x = np.linspace(max(d0 - 0.2, 0.0001), min(d0l,afar-0.200000000000001) + 0.2, 100)

plt.axvline(x=d0, color='r', label='d0')
plt.axvline(x=d0l, color='g', label='d0l')
plt.axvline(x=afar, color='b', label='afar')
ys = nvph_farmin(h,x,bf)
plt.plot(x, ys)

min_index = np.argmin(ys)
print(min(ys))
print(nvph_farmin(h,d0l,bf))
print(nvph_farmin(h,d0,bf))
min_x = x[min_index]
min_y = ys[min_index]
plt.plot(min_x, min_y, 'ro', label='Lowest point')
plt.show()
