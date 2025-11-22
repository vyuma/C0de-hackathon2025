"use client"

import { useEffect, useState } from "react";

type Props = {
    message: string,
    duration: number,
}

export default function AutoPopup({ message, duration=3000 }: Props) {
    const [visible, setVisible] = useState(true);

    useEffect(() => {
        const timer = setTimeout(() => {
            setVisible(false);
        }, duration);

        return () => clearTimeout(timer);
    }, [duration]);

    if (!visible) return null;

    return (
        <div className="z-50 fixed w-10/12 top-3 left-1/2 transform -translate-x-1/2 bg-gray-800 text-white px-6 py-3 text-2xl rounded shadow-lg">
            {message}
        </div>
    );
}
