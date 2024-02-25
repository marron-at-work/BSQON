#pragma once

#include <cstdint>

#include "json.hpp"
typedef nlohmann::json json;

namespace BSQON
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
}

