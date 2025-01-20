#pragma once

#include <cstdint>
#include <string>

#include <optional>
#include <vector>
#include <set>
#include <map>
#include <list>

#include "json.hpp"
typedef nlohmann::json json;

#include "brex.h"
#include "brex_parser.h"
#include "brex_compiler.h"
#include "brex_executor.h"
#include "brex_system.h"

#include "path.h"
#include "path_fragment.h"
#include "path_glob.h"

namespace bsqon
{
    struct TZDateTime
    {
        uint16_t year;   // Year since 1900
        uint8_t month;   // 0-11
        uint8_t day;     // 1-31
        uint8_t hour;    // 0-23
        uint8_t min;     // 0-59
        uint8_t sec;     // 0-60

        char* tzdata; //timezone name as spec in tzdata database
    };

    struct TIATime
    {
        uint16_t year;   // Year since 1900
        uint8_t month;   // 0-11
        uint8_t day;     // 1-31
        uint8_t hour;    // 0-23
        uint8_t min;     // 0-59
        uint8_t sec;     // 0-59
    };

    struct PlainDate
    {
        uint16_t year;   // Year since 1900
        uint8_t month;   // 0-11
        uint8_t day;     // 1-31
    };

    struct PlainTime
    {
        uint8_t hour;    // 0-23
        uint8_t min;     // 0-59
        uint8_t sec;     // 0-60
    };

    struct ISOTimeStamp
    {
        uint16_t year;   // Year since 1900
        uint8_t month;   // 0-11
        uint8_t day;     // 1-31
        uint8_t hour;    // 0-23
        uint8_t min;     // 0-59
        uint8_t sec;     // 0-60
        uint16_t millis; // 0-999
    };

    struct DeltaDateTime
    {
        //Leading value is always in range -- e.g. if year is set then month must be 0-11, etc.
        uint16_t year;   
        uint16_t month;   
        uint32_t day;     
        uint32_t hour;    
        uint32_t min;     
        uint32_t sec;     

        char8_t sign;    // '+' or '-'
    };

    struct DeltaISOTimeStamp
    {
        //Leading value is always in range -- e.g. if year is set then month must be 0-11, etc.
        uint16_t year;   
        uint32_t month; 
        uint32_t day;   
        uint32_t hour;   
        uint32_t min; 
        uint32_t sec;   
        uint32_t millis; 

        char8_t sign;    // '+' or '-'
    };
}

