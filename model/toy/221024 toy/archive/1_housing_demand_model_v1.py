import numpy as np
from scipy.optimize import root
from scipy.stats import pareto
import matplotlib.pyplot as plt
from numpy import log, exp, power
from timeit import default_timer as timer
from pprint import pprint
start = timer()

def encode_prices(ph,pl,parameters):
    later_half = log(ph/pl-1)
    first_half0 = parameters['m'].min()/pl[0]-1 # first element of L type is the outside option
    first_half = np.concatenate(([first_half0],pl[1:]))
    logpv = np.concatenate((log(first_half),later_half))
    return logpv

def decode_prices(logpv,parameters):
    split = np.array_split(logpv, 2)
    pl0 = parameters['m'].min()/(exp(split[0][0])+1)
    pl = np.concatenate(([pl0],exp(split[0][1:])))
    ph = (exp(split[1])+1)*pl
    return ph,pl

def A3_initiate_prices(parameters):
    initial_price = parameters['alpha']*parameters['m'].min()
    pl = np.ones(parameters['location_count']) * initial_price
    ph = pl * 2
    logpv = encode_prices(ph,pl,parameters)
    return logpv

def A2_generate_income_groups(parameters):
    x = np.linspace(0.1,0.9, parameters['income_bin_count'])
    b = 1
    parameters.update({
        'Lm' : np.ones(parameters['income_bin_count'])*100/parameters['income_bin_count'],
        'm' : pareto.ppf(x, b)
    })
    # print(pareto.ppf(x, b))
    # plt.scatter(x,pareto.ppf(x, b))
    # plt.show()
    return parameters

def B1_worker_decision(logpv,parameters):
    ph, pl = decode_prices(logpv,parameters)
    m = parameters['m'][np.newaxis]
    con_h = m.T-ph
    con_l = m.T-pl
    con_h[con_h<0]=0
    con_l[con_l<0]=0
    exp_uh = parameters['a']*power((con_h),(1-parameters['alpha']))*power(parameters['H'],parameters['alpha'])
    exp_ul = parameters['a']*power((con_l),(1-parameters['alpha']))
    htype_h = exp_uh-exp_ul
    htype_h[htype_h<0]=0
    htype_h[htype_h>0]=1
    exp_u = np.maximum(exp_uh,exp_ul)

    exp_ut = power(exp_u,parameters['theta'])
    div = np.sum(exp_ut, axis=1)[np.newaxis]
    prob = exp_ut/div.T # axis 1 is location, axis 0 is income
    return prob, htype_h, exp_u

def B2_derive_housing_demand(htype_h,prob,parameters):
    Lm = parameters['Lm'][np.newaxis]
    pLm = prob*Lm.T
    htype_hd = np.sum(htype_h*pLm, axis = 0)
    htype_ld = np.sum((-htype_h+1)*pLm, axis = 0)
    htype_dv = encode_htype_vec(htype_hd,htype_ld)
    return htype_dv

def encode_htype_vec(htype_hk,htype_lk):
    htype_v = np.concatenate((htype_hk,htype_lk))
    return htype_v

def decode_htype_vec(htype_v):
    split = np.array_split(htype_v, 2)
    htype_hk = split[0]
    htype_lk = split[1]
    return htype_hk, htype_lk

def B_demand_structure(logpv,parameters):
    prob, htype_h, exp_u = B1_worker_decision(logpv,parameters)
    htype_dv = B2_derive_housing_demand(htype_h,prob,parameters)
    return htype_dv

def A1_initiate_parameters():
    parameters = {}
    parameters.update({
        'income_bin_count' : 2,
        'people_count' : 100,
        'location_count' : 2,
        'htype_supply_ratio' : 4,
        'h_share' : 0.8
    })
    parameters.update({
        'alpha' : 0.3,
        'H' : 2, # normalize logL to 0
        'theta' : 5
    })
    return parameters

def A4_initiate_locations(parameters):
    x = np.linspace(0.1,0.9, parameters['location_count'])
    b = 2
    parameters.update({
        'a' : pareto.ppf(x, b)
    })
    # print(pareto.ppf(x, b))
    # plt.scatter(x,pareto.ppf(x, b))
    # plt.show()
    return parameters

def A5_generate_housing_supply(parameters,h_share):
    land_size = parameters['people_count']/parameters['location_count']
    htype_hs = np.ones(parameters['location_count']-1)*land_size*h_share/parameters['htype_supply_ratio']
    htype_hs = np.concatenate(([0],htype_hs))
    htype_ls = np.ones(parameters['location_count']-1)*land_size*(1-h_share)
    residual_supply = parameters['people_count']-sum(htype_hs)-sum(htype_ls)
    htype_ls = np.concatenate(([residual_supply],htype_ls))
    htype_sv = encode_htype_vec(htype_hs,htype_ls)
    return htype_sv

def A_initiate_task():
    parameters = A1_initiate_parameters()
    parameters = A2_generate_income_groups(parameters)
    logpv0 = A3_initiate_prices(parameters)
    parameters = A4_initiate_locations(parameters)
    htype_sv = A5_generate_housing_supply(parameters,h_share=parameters['h_share'])
    return parameters,logpv0,htype_sv

parameters,logpv0,htype_sv = A_initiate_task()


def demand_function(logpv,parameters,htype_sv):
    # ph,pl = decode_prices(logpv,parameters)
    # print(ph)
    # print(pl)
    htype_dv = B_demand_structure(logpv,parameters)
    # print(htype_dv-htype_sv)
    return (htype_dv-htype_sv)

# generate housing supply
# out = fsolve(demand_function,logpv0,args=(parameters,htype_sv))
out = root(demand_function,logpv0,args=(parameters,htype_sv),method='lm')

pprint(demand_function(out.x,parameters,htype_sv))

print(timer() - start)

## Need to account for the case when people are indifferent