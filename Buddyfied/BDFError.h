//
//  BDFError.h
//  Buddyfied
//
//  Created by Tom Gilbert on 02/07/2014.
//  Copyright (c) 2014 Tom Gilbert. All rights reserved.
//

#ifndef Buddyfied_BDFError_h
#define Buddyfied_BDFError_h

extern NSString* const BDFErrorDomain;

enum {
    BDFUsernameTooShortError = 1000,
    BDFInvalidEmailError,
    BDFPasswordComplexityError,
    BDFInvalidResponseType,
    BDFRegistrationError
};

#endif
