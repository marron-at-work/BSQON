#pragma once

#include <cstdint>
#include <string>

#include <optional>
#include <vector>
#include <set>
#include <map>

#include "json.hpp"
typedef nlohmann::json json;

#include "../build/include/brex/regex/brex.h"
#include "../build/include/brex/regex/brex_parser.h"
#include "../build/include/brex/regex/brex_executor.h"

#include "../build/include/brex/path/path.h"
#include "../build/include/brex/path/path_fragment.h"
#include "../build/include/brex/path/path_glob.h"

namespace bsqon
{
    struct DateTime
    {
        uint16_t year;   // Year since 1900
        uint8_t month;   // 0-11
        uint8_t day;     // 1-31
        uint8_t hour;    // 0-23
        uint8_t min;     // 0-59
        uint8_t sec;     // 0-60

        char* tzdata; //timezone name as spec in tzdata database
    };

    struct UTCDateTime
    {
        uint16_t year;   // Year since 1900
        uint8_t month;   // 0-11
        uint8_t day;     // 1-31
        uint8_t hour;    // 0-23
        uint8_t min;     // 0-59
        uint8_t sec;     // 0-60
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
        int16_t year;   
        int16_t month;   
        int32_t day;     
        int32_t hour;    
        int32_t min;     
        int32_t sec;     

        char8_t sign;    // '+' or '-'
    };

    struct DeltaPlainDate
    {
        //Leading value is always in range -- e.g. if year is set then month must be 0-11, etc.
        int16_t year;   
        int16_t month;   
        int32_t day;     

        char8_t sign;    // '+' or '-'
    };

    struct DeltaPlainTime
    {
        //Leading value is always in range -- e.g. if hour is set then min must be 0-59, etc.
        int32_t hour;
        int32_t min;
        int32_t sec;

        char8_t sign;    // '+' or '-'
    };

    struct DeltaISOTimeStamp
    {
        //Leading value is always in range -- e.g. if year is set then month must be 0-11, etc.
        int16_t year;   
        int32_t month; 
        int32_t day;   
        int32_t hour;   
        int32_t min; 
        int32_t sec;   
        int32_t millis; 

        char8_t sign;    // '+' or '-'
    };
}

