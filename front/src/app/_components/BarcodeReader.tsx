"use client"

import { BrowserMultiFormatReader } from '@zxing/browser';
import { useEffect, useState, useRef } from 'react';

function Spinner() {
    return (
        <div className="fixed inset-0 bg-white bg-opacity-70 flex items-center justify-center z-50">
            <div className="animate-spin rounded-full h-16 w-16 border-4 border-gray-300 border-t-black"></div>
        </div>
    )

}

type PostInfo = {
    title: string;
    author: string;
    coverImageUrl: string;
    isbn: string;
    description: string;
    status: string;
    lastModified: string;
    statusChangedAt: string;
}

export default function BarcodeReader() {
    const videoRef = useRef<HTMLVideoElement>(null);
    const [isbnText, setISBNText] = useState("");
    const [bookTitle, setBookTitle] = useState("");
    const [modalOpen, setModalOpen] = useState(false);
    const [loading, setLoading] = useState(false);

    useEffect(() => {
        const codeReader = new BrowserMultiFormatReader();

        if (videoRef.current) {
            codeReader
            .decodeFromVideoDevice(undefined, videoRef.current, (result, err) => {
                if (result && !modalOpen) {
                    setISBNText(result.getText());
                    setModalOpen(true);
                }
            })
        }

        return () => {}
    }, []);

    useEffect(() => {
        if (isbnText.length == 0) return;
        console.log("ISBN Detected: ", isbnText);
        setLoading(true);

        const fetchBook = async () => {
            try {
                console.log("Fetching book info for ISBN:", isbnText);
                const response = await fetch(`http://[::1]:8000/external/bookinfo/${isbnText}`);
                if (!response.ok) throw new Error("Failed to fetch book info");
                const data = await response.json() as PostInfo;
                setBookTitle(data.title);
                setModalOpen(true);
            } catch (error) {
                console.error("Error fetching book info:", error);
                setBookTitle("不明な書籍");
                setModalOpen(true);
            } finally {
                setLoading(false);
            }
        };

        fetchBook();
    }, [isbnText]);

    return (
        <>
            { loading && <Spinner />}
            {
                (!loading && modalOpen) && ( 
                <div className="fixed inset-0 bg-white flex flex-col items-center justify-center z-50 text-center">
                    <p>「{bookTitle}」で間違いありませんか？</p>
                    <div className="flex">
                        <button
                            onClick={() => {
                                setModalOpen(false);
                                setBookTitle("");
                                setISBNText("");
                            }}
                            className="mx-4 my-10 px-10 py-4 bg-blue-500 text-white rounded"
                            >
                            確認
                        </button>
                        <button
                            onClick={() => {
                                setModalOpen(false);
                                setBookTitle("");
                                setISBNText("");
                            }}
                            className="mx-4 my-10 px-6 py-4 bg-gray-300 rounded"
                            >
                            再読み取り
                        </button>
                    </div>
                </div>
                )
            }
            <video ref={videoRef} style={{width: "100%"}}/>
            <button onClick={() => {
                setISBNText("9784087448221");
            }} className="mt-4 px-4 py-2 bg-blue-500 text-white rounded">
                バーコード読み取りテスト
            </button>
        </>
    );
}