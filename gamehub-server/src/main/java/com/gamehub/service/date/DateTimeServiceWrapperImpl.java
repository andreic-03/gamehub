package com.gamehub.service.date;

import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

@Service
public class DateTimeServiceWrapperImpl implements DateTimeServiceWrapper {
    @Override
    public LocalDateTime now() {
        return LocalDateTime.now();
    }
}
