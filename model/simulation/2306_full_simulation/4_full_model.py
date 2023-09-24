import matplotlib.pyplot as plt
import numpy as np
from scipy.optimize import fsolve
import scipy
from scipy.stats import invweibull
import math

from argparse import ArgumentParser

#################### Options

P = ArgumentParser()
P.add_argument("-noguess", help="", action = 'store_true')
P.add_argument("-sfz", help="", action = 'store_true')
args = P.parse_args()

J = 3
N_group = 2
setting ={
    'discretized_group' : 10,
    'approximate_sfz' : not args.sfz
}

#################### Utility Functions
def generate_matrix(J):
    matrix = np.zeros((J, J))
    for i in range(J):
        for j in range(J):
            matrix[i, j] = 1/(abs(i - j)/2 + 1)
    return matrix

def index_trans(i,g):
    return g*J + i 

#################### Main Procedure
def preparation(J,N_group):
    '''
        This function will define all the parameters and fundamentals
        for the model. In particular, it will define
            para: a dict of model parameters
            fund: a dict of model fundamentals
            poli: a dict of zoning policies
            Ne: a list of endowment distribution
            e: endowment amount
            F_scale: a list of F_scale
    '''
    para = {
        'gamma' : 0.5,
        'beta' : 0.3,
        'ubf' : 0.3,
        'alpha' : 0.7,
        'theta' : 3,
        'eta' : 3,
        'zp' : 1
    }

    para.update({
        'zb' : (1-para['beta']) ** (1-para['beta']) * para['beta'] ** para['beta'],
        'za' : (1-para['alpha']) ** (1-para['alpha']) * para['alpha'] ** para['alpha']
    })

    fund = {
        'tau' : generate_matrix(J),
        'A' : np.arange(J, 0, -1),
        'B' : np.ones(J),
        'u' : np.ones(J),
        'D' : np.ones(J)
    }

    if args.sfz:
        ### write down how to define sfz
        poli = {
            'bf' : np.ones(2*J)*1000,
            # 'Dg' : np.ones(2*J)/2
        }
    else:
        poli = {
            'bf' : np.ones(2*J)*1000,
            'Dg' : np.hstack((np.ones(J),np.zeros(J)))
        }

    Ne = np.ones(N_group)
    e = np.arange(1, N_group + 1)
    F_scale = define_F_scale(fund,para)
    pL0 = np.hstack((np.ones(J),np.ones(J)*0.9))
    return para, fund, poli, Ne, e, F_scale, pL0

def define_F_scale(fund,para):
    F_scale = np.ones(J)
    for i in range(J):
        num = 0
        for j in range(J):
            num += (fund['A'][j] * fund['tau'][i,j]) ** para['theta']
        F_scale[i] = num ** (1/para['theta'])
    return F_scale

def define_land_decision_rule(poli,pL):
    '''
        This function will output a list of income, such that those
        with income larger than y will opt for land 2.

        Think about how to know if a restriction is binding.
        Think about the marginal group.
        The group that will choose sfh base on land 1 price
        and the group that will choose sfh base on land 2 price.

        I could evaluate once to check if the quality demanded is
        better to be produced on land 1 or land 2. Instead of calculating
        a specific cutoff

        When evaluating a price, I may need a linear interpolation. 
    '''
#################### Implementation
para, fund, poli, Ne, e, F_scale, pL0 = preparation(J,N_group)

class equilibrium:
    '''
        Given land price, this will calculate the aggregate land demand. 
        This is used to solve for the equilibrium. 
    '''
    def __init__(self) -> None:
        pass

class endowment_group:
    def __init__(self,endowment):
        self.endowment = endowment
        self.incpdf_grid = self.obtain_incpdf_grid()
        self.inc_obj = res_income_group()
    
    def make_decision(self,pL):
        # TODO: I need to summarize the amount of land in d1 that is occupied by SFH.

        ui_ematrix = np.empty((self.incpdf_grid.shape))
        land_ematrix = np.empty((self.incpdf_grid.shape))
        dgi_ematrix = np.empty((self.incpdf_grid.shape))
        d1_ematrix = np.empty((self.incpdf_grid.shape))

        for inc_index in range(self.incpdf_grid.shape[0]):
            for i in range(self.incpdf_grid.shape[1]):
                income = self.incpdf_grid[inc_index,i]
                ui_ematrix[inc_index,i], land_ematrix[inc_index,i], dgi_ematrix[inc_index,i], \
                    d1_ematrix[inc_index,i] = self.inc_obj.make_decisions(income,i,pL)

        res_utility = np.mean(ui_ematrix, axis=0) ** para['eta']
        pi_i = res_utility/np.sum(res_utility)
        

        return ui_ematrix, land_ematrix, dgi_ematrix, d1_ematrix, pi_i

    def obtain_incpdf_grid(self):
        p_grid = np.linspace(0, 1, setting['discretized_group']+2)[1:-1]

        matrix = np.empty((setting['discretized_group'], J))
        for i in range(len(F_scale)):
            value = F_scale[i]
            column = invweibull.ppf(p_grid, c = para['theta'], loc = 0, scale= value * self.endowment)
            matrix[:,i] = column
        return matrix

class res_income_group:
    '''
        [[Feature to be update]] In future version, bf will play a role

        This class will take in income, FAR, and land price, and will return
            the location and demand for land, the demand for land 1, and the indirect utility. 

        This class will contain all the housing functions.
    '''
    def make_decisions(self,income,i,pL):
        income = income
        land1_index = i
        land2_index = index_trans(i,1)
        FAR1 = poli['bf'][land1_index]
        FAR2 = poli['bf'][land2_index]
        land_price1 = pL[land1_index]
        land_price2 = pL[land2_index]
        h1, d1, u1= self.obtain_land1_consumption(income,FAR1,land_price1,fund['u'][i])
        h2, d2, u2= self.obtain_land2_consumption(income,FAR2,land_price1,land_price2,fund['u'][i])
        ui = max(u1,u2)
        land_index = [u1,u2].index(ui)
        dgi = [d1,d2][land_index]
        return ui, land_index, dgi, d1
    
    def obtain_land2_consumption(self,income,FAR2,land_price1,land_price2,res_amenity):
        if self.sfh_exclusion(income,land_price1,land_price2):
            return 0,0,0 
        h2 = self.h_sfz(income,land_price2)
        d2 = min(self.d_nr(h2,land_price2),1)
        cost = self.hprice_sfz(h2,land_price2,d2)
        u2 = self.utility_fuct(income - cost,h2,res_amenity)
        return h2, d2, u2

    def obtain_land1_consumption(self,income,FAR1,land_price1,res_amenity):
        if self.nr_exclusion(income,land_price1):
            return 0, 0, 0
        h1 = self.h_nr(income,land_price1)
        d1 = self.d_nr(h1,land_price1)
        cost = self.hprice_nr(h1,land_price1)
        u1 = self.utility_fuct(income - cost,h1,res_amenity)
        return h1, d1, u1
    
    def sfh_exclusion(self,income,land_price1,land_price2):
        if land_price1 < land_price2:
            return True
        return income - land_price2 - para['ubf'] ** (1/para['gamma']) <= 0

    def nr_exclusion(self,income,land_price):
        return income - para['ubf']*self.base_bp(land_price) <= 0

    def utility_fuct(self,disp_inc,h,res_amenity):
        return res_amenity * disp_inc ** para['alpha'] * h ** (1-para['alpha'])

    ########################## SFZ
    def sfz_nr_dummy(self,w,kappa):
        return self.b(self.h_nr(w,kappa)) >= self.g(kappa)

    def h_opt(self,h,w,kappa):
        A = (para['ubf']+h/para['zb'])**(1/para['gamma'])
        B = para['alpha'] * para['ubf'] * para['gamma'] * para['zb'] + para['alpha'] * para['gamma'] * h - para['alpha'] * h - para['ubf'] * para['gamma'] * para['zb'] - para['gamma'] * h
        C = (para['alpha']-1)*para['gamma']*(para['ubf']*para['zb']+h)
        return -w + kappa + A * B / C

    def h_opt_guess(self,w,kappa):
        A = w - kappa - para['ubf'] ** 1/para['gamma']
        B = (para['alpha'] - 1) * para['gamma']
        C = para['alpha'] * para['gamma'] - para['alpha'] - para['gamma']
        return (A * B /C) ** para['gamma'] * para['zp']

    def h_sfz(self,w,kappa):
        if w <= kappa + para['ubf'] ** 1/para['gamma']:
            return 0
        if self.sfz_nr_dummy(w,kappa):
            return self.h_nr(w,kappa)
        if setting['approximate_sfz']:
            return self.h_opt_guess(w,kappa)
        result = fsolve(self.h_opt, self.h_opt_guess(w,kappa), args=(w,kappa))
        return result[0]

    def hprice_sfz(self,h,kappa,d2):
        if d2 < 1:
            return self.b(h) *self.base_bp(kappa)
        else:
            b1 = self.b(h)
            return b1 ** (1/para['gamma']) + kappa
    
    ################## NR
    def hprice_nr(self,h,land_price):
        return self.base_bp(land_price) * (h/para['zb']+para['ubf'])

    def base_bp(self,kappa):
        return (1 / para['gamma']) * ((1 / para['gamma'] - 1) ** (para['gamma'] - 1)) * (kappa ** (1 - para['gamma']))

    def h_nr(self,w,kappa):
        return (1-para['alpha'])*(w-para['ubf']*self.base_bp(kappa))*para['zb']/self.base_bp(kappa)

    def b(self,h):
        return h/para['zb'] + para['ubf']

    def g(self,kappa):
        return (kappa/(1/para['gamma']-1))**(para['gamma'])

    def d_nr(self,h,kappa):
        return self.b(h) **(-1) * self.g(kappa)
    

egroup_obj = endowment_group(1)
egroup_obj.make_decision(pL0)
inc_group_obj = res_income_group()
'''
    Steps:
        Define endowment specific class that can do the following:
            Given land prices and zoning policies, output the land demand distribution and
                the residential distribution, 

            Given income, land prices, and zoning policies, make consumption decisions.

            On the demand side, I assume land selection base on income. 

'''
